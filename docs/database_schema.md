# PalengkeGo Database Schema — Firebase

> **Backend**: Firebase (Firestore + Auth + Cloud Storage + Cloud Messaging)
> **Version**: 1.0 — Initial Schema Design
> **Date**: May 27, 2026

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Firestore Data Model](#firestore-data-model)
3. [Collection Definitions](#collection-definitions)
4. [Category-Based Filtering Logic](#category-based-filtering-logic)
5. [Firestore Security Rules](#firestore-security-rules)
6. [Cloud Storage Structure](#cloud-storage-structure)
7. [Composite Indexes](#composite-indexes)
8. [Denormalization Strategy](#denormalization-strategy)

---

## Architecture Overview

PalengkeGo has two user roles operating within the same Firebase Auth system:

- **Buyers** — Browse the market, add items to cart, place orders, track deliveries, view recipes.
- **Vendors** — Manage their stall, add/edit products, receive and fulfill orders, view earnings.

A single Firebase Auth user can have **both** a buyer profile and a vendor stall simultaneously (a buyer who starts selling becomes a vendor without losing their buyer account).

### Key Design Decisions

1. **Product categories live on PRODUCTS, not on stalls.** A fish stall that adds a meat product will appear in the "Meat" filter. The stall's `primaryCategory` is only for display/branding — filtering is always driven by product-level `category` fields.
2. **Firebase Auth** handles authentication. All documents reference `auth.uid` for ownership.
3. **Denormalize aggressively.** Firestore has no JOINs — any data needed at read time must be embedded or duplicated in the document. We accept write-time cost for read-time speed.
4. **Subcollections** for 1:many relationships that don't need cross-parent queries (e.g., `orders/{orderId}/items`).
5. **Top-level collections** for data that needs global queries (e.g., all products across all stalls for category filtering).
6. **Soft deletes** for products and orders — never hard delete transactional data.

### Why Certain Data Is Denormalized

Firestore charges per document read and cannot JOIN across collections. Key denormalizations:

| Duplicated Field | Where | Why |
|-----------------|-------|-----|
| `stall.name`, `stall.imageUrl` | In every `product` doc | So the product list doesn't need a second read to show stall info |
| `product.name`, `product.price` | In every `orderItem` doc | Snapshot at time of purchase — prices change over time |
| `stall.name`, `stall.avatarUrl` | In every `order` doc | So order history renders without stall lookups |
| `buyer.displayName` | In every `order` doc | So vendor order list shows buyer name without extra read |

---

## Firestore Data Model

```
firestore-root/
│
├── users/                          ← Buyer profiles
│   └── {uid}/
│       ├── (profile fields)
│       ├── addresses/              ← Subcollection
│       │   └── {addressId}/
│       ├── favorites/              ← Subcollection (Hearted Recipes)
│       │   └── {recipeId}/
│       └── paymentMethods/         ← Subcollection
│           └── {methodId}/
│
├── stalls/                         ← Vendor stalls
│   └── {stallId}/
│       ├── (stall fields)
│       └── operatingHours/         ← Subcollection
│           └── {dayOfWeek}/
│
├── products/                       ← TOP-LEVEL (enables cross-stall queries)
│   └── {productId}/
│
├── categories/                     ← Reference data
│   └── {categoryId}/
│
├── orders/                         ← All orders
│   └── {orderId}/
│       └── items/                  ← Subcollection
│           └── {itemId}/
│
├── carts/                          ← Shopping carts
│   └── {uid}/
│       └── items/                  ← Subcollection
│           └── {cartItemId}/
│
├── reviews/                        ← All reviews
│   └── {reviewId}/
│
├── notifications/                  ← All notifications
│   └── {notificationId}/
│
├── recipes/                        ← Community recipes
│   └── {recipeId}/
│       └── ingredients/            ← Subcollection
│           └── {ingredientId}/
│
├── promos/                         ← Vendor promotions
│   └── {promoId}/
│
└── inventoryAlerts/                ← Stock alerts
    └── {alertId}/
```

---

## Collection Definitions

### 1. `users` — Buyer Profiles

Created on registration. Document ID = Firebase Auth UID.

```
users/{uid}
```

```javascript
{
  displayName: "Juan Dela Cruz",          // string
  email: "juan@email.com",               // string
  phoneNumber: "+63 912 345 6789",       // string | null
  avatarUrl: "gs://bucket/avatars/...",   // string | null
  role: "buyer",                          // "buyer" | "vendor" | "both"
  stallId: null,                          // string | null — links to stalls/{stallId} if vendor
  createdAt: Timestamp,                   // Firestore Timestamp
  updatedAt: Timestamp                    // Firestore Timestamp
}
```

#### Subcollection: `users/{uid}/addresses`

```javascript
{
  label: "Home",                          // "Home" | "Work" | "Other"
  address: "123 Rizal St, Brgy. San Jose, Quezon City",
  latitude: 14.6507,                      // number | null
  longitude: 121.0495,                    // number | null
  isDefault: true,                        // boolean
  createdAt: Timestamp
}
```

#### Subcollection: `users/{uid}/favorites` (Hearted Recipes)

```javascript
// Document ID matches the Recipe ID
{
  recipeId: "recipe-uuid",                // string — matches document ID
  title: "Sinigang na Bangus",            // string — denormalized for quick display
  imageUrl: "https://...",                // string | null — denormalized
  savedAt: Timestamp                      // Firestore Timestamp
}
```

---

### 2. `stalls` — Vendor Stalls

Each vendor owns exactly one stall. `primaryCategory` is for branding/display only — it does NOT control filtering.

```
stalls/{stallId}
```

```javascript
{
  ownerId: "firebase-auth-uid",           // string — FK to auth.uid
  name: "Juan's Fresh Catch",            // string
  primaryCategory: "Fish",               // string — display only, NOT for filtering
  description: "Fresh seafood daily...",  // string | null
  stallLocation: "Stall 14, Wet Market", // string
  imageUrl: "https://...",               // string | null — stall banner
  avatarUrl: "https://...",              // string | null — stall logo
  isOpen: true,                          // boolean
  isVerified: false,                     // boolean
  rating: 4.8,                           // number (cached avg)
  reviewCount: 24,                       // number (cached count)
  totalOrders: 152,                      // number (cached count)
  totalEarnings: 45200.00,              // number (cached sum)

  // Denormalized: list of category names this stall has products in
  // Updated via Cloud Function whenever a product is added/edited/deleted
  activeCategories: ["Fish", "Meat"],    // string[] — ENABLES category filter

  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

> [!IMPORTANT]
> **`activeCategories`** is the key field that makes the category filter work without querying every product. It's a denormalized array maintained by a Cloud Function trigger on the `products` collection. When a vendor adds a "Meat" product to their fish stall, "Meat" gets appended to this array.

#### Subcollection: `stalls/{stallId}/operatingHours`

```
stalls/{stallId}/operatingHours/{dayOfWeek}
```

```javascript
// dayOfWeek: "0" (Sunday) through "6" (Saturday)
{
  openTime: "06:00",                     // string (HH:mm)
  closeTime: "18:00",                    // string (HH:mm)
  isClosed: false                        // boolean
}
```

---

### 3. `products` — All Products (Top-Level)

**Top-level collection** so we can query products across all stalls. This is critical for the category filter.

```
products/{productId}
```

```javascript
{
  stallId: "stall-uuid",                  // string — FK to stalls
  category: "Meat",                       // string — THE filtering field
  name: "Beef Jerky",                     // string
  description: "Sun-dried premium beef",  // string | null
  price: 280.00,                          // number
  unit: "kg",                             // "kg" | "piece" | "bundle" | "pack"
  weight: "1kg",                          // string — display weight
  pricePerKg: "₱280/kg",                 // string | null — display string
  imageUrl: "https://...",                // string | null
  stockQty: 15.0,                         // number
  lowStockThreshold: 5.0,                // number
  isAvailable: true,                      // boolean
  isDeleted: false,                       // boolean — soft delete

  // Denormalized stall info (avoids extra reads when listing products)
  stallName: "Juan's Fresh Catch",        // string
  stallImageUrl: "https://...",           // string | null
  stallIsOpen: true,                      // boolean

  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

| Field | Purpose |
|-------|---------|
| `category` | **THE field** that drives filtering. Independent of stall's `primaryCategory`. |
| `stallId` | Links back to parent stall for navigation |
| `stallName`, `stallImageUrl` | Denormalized — avoids a second read when displaying product cards |
| `isDeleted` | Soft delete preserves order history references |

---

### 4. `categories` — Product Categories

Small reference collection. Rarely changes.

```
categories/{categoryId}
```

```javascript
{
  name: "Meat",                           // string — unique
  iconName: "restaurant",                // string — Flutter icon identifier
  sortOrder: 3,                          // number — display order in filter bar
  createdAt: Timestamp
}
```

**Seed data:**

| name | iconName | sortOrder |
|------|----------|-----------|
| Fruits | nutrition | 1 |
| Vegetables | eco | 2 |
| Meat | restaurant | 3 |
| Chicken | egg_alt | 4 |
| Fish | set_meal | 5 |
| Dried Goods | inventory_2 | 6 |
| Spices | local_fire_department | 7 |
| Dairy | water_drop | 8 |

---

### 5. `orders` — Customer Orders

```
orders/{orderId}
```

```javascript
{
  orderNumber: "RG-1029",                // string — human-readable
  buyerId: "firebase-auth-uid",          // string
  stallId: "stall-uuid",                 // string
  status: "preparing",                   // string (see lifecycle below)

  // Denormalized buyer info (so vendor doesn't need extra read)
  buyerName: "Maria Santos",             // string
  buyerPhone: "+63 917 123 4567",       // string | null

  // Denormalized stall info (so buyer order history doesn't need extra read)
  stallName: "Juan's Fresh Catch",       // string
  stallImageUrl: "https://...",          // string | null

  isPickup: true,                        // boolean
  deliveryAddress: null,                 // string | null
  subtotal: 450.00,                      // number
  deliveryFee: 0.00,                     // number
  total: 450.00,                         // number
  
  // --- PayMongo Payment Integration ---
  paymentMethod: "paymongo_gcash",       // "cod" | "paymongo_gcash" | "paymongo_card" | "paymongo_paymaya"
  paymentStatus: "unpaid",               // "unpaid" | "paid" | "failed" | "refunded"
  paymentIntentId: "pi_12345abcd",       // string | null — PayMongo Payment Intent Reference
  checkoutUrl: "https://paymongo...",    // string | null — URL for the buyer to complete payment
  
  notes: "Please remove scales",         // string | null

  placedAt: Timestamp,
  confirmedAt: null,                     // Timestamp | null
  completedAt: null,                     // Timestamp | null
  cancelledAt: null,                     // Timestamp | null
  cancelReason: null                     // string | null
}
```

**Order Status Lifecycle:**
```
pending → confirmed → preparing → ready → out_for_delivery → delivered → completed
                                                                    ↘ cancelled
```

#### Subcollection: `orders/{orderId}/items`

```javascript
{
  productId: "product-uuid",              // string — reference (may be soft-deleted)
  productName: "Bangus (Milkfish)",      // string — SNAPSHOT at time of order
  quantity: 2,                           // number
  unitPrice: 180.00,                     // number — SNAPSHOT at time of order
  weight: "1kg",                         // string
  pricePerKg: "₱180/kg",               // string | null
  imageUrl: "https://...",               // string | null
  total: 360.00                         // number
}
```

> [!NOTE]
> `productName`, `unitPrice`, `weight`, and `imageUrl` are **snapshots** — they capture the product's state at the moment of purchase. This ensures order history stays accurate even if the vendor later changes prices or renames products.

---

### 6. `carts` — Shopping Carts

```
carts/{uid}/items/{cartItemId}
```

```javascript
{
  productId: "product-uuid",              // string
  quantity: 2,                           // number (>= 1)

  // Denormalized product info (renders cart without product reads)
  productName: "Bangus (Milkfish)",      // string
  price: 180.00,                         // number
  weight: "1kg",                         // string
  pricePerKg: "₱180/kg",               // string
  imageUrl: "https://...",               // string
  stallName: "Juan's Fresh Catch",       // string
  stallId: "stall-uuid",                 // string

  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

> [!TIP]
> Cart items are heavily denormalized so the shopping cart screen renders with **zero additional reads**. A Cloud Function can periodically sync prices if a vendor updates them, or the app can validate at checkout time.

---

### 7. `reviews` — Stall Reviews

```
reviews/{reviewId}
```

```javascript
{
  buyerId: "firebase-auth-uid",          // string
  buyerName: "Ricardo D.",               // string — denormalized
  stallId: "stall-uuid",                 // string
  orderId: "order-uuid",                // string | null
  rating: 5,                            // number (1-5)
  comment: "Super fresh tilapia...",    // string | null
  createdAt: Timestamp
}
```

---

### 8. `notifications` — All Notifications (Buyer + Vendor)

```
notifications/{notificationId}
```

```javascript
{
  userId: "firebase-auth-uid",           // string — recipient
  type: "new_order",                     // string (see table below)
  title: "New Order Received!",          // string
  body: "Order #RG-1030 from Maria Santos is ready for preparation.",
  data: {                                // map — arbitrary payload
    orderId: "order-uuid",
    stallId: "stall-uuid"
  },
  isRead: false,                         // boolean
  createdAt: Timestamp
}
```

| `type` value | Target | Description |
|-------------|--------|-------------|
| `order_placed` | Buyer | Your order was placed |
| `order_confirmed` | Buyer | Vendor confirmed your order |
| `order_ready` | Buyer | Order is ready for pickup/delivery |
| `order_delivered` | Buyer | Order delivered |
| `order_cancelled` | Buyer | Order was cancelled |
| `new_order` | Vendor | New order received |
| `low_stock` | Vendor | Product below threshold |
| `review_received` | Vendor | New customer review |
| `admin_announcement` | Both | Market-wide announcement |
| `promo` | Buyer | Vendor promotion/sale |

---

### 9. `recipes` — Community Recipes

```
recipes/{recipeId}
```

```javascript
{
  title: "Sinigang na Bangus",           // string
  category: "Seafood",                   // string
  description: "Classic Filipino sour soup...",
  prepTime: "30 mins",                   // string
  difficulty: "Easy",                    // "Easy" | "Medium" | "Hard"
  imageUrl: "https://...",               // string | null
  servings: 4,                          // number
  instructions: [                        // string[]
    "Boil water with tamarind mix.",
    "Add bangus slices and vegetables.",
    "Season with fish sauce and serve hot."
  ],
  createdAt: Timestamp
}
```

#### Subcollection: `recipes/{recipeId}/ingredients`

```javascript
{
  name: "Bangus (Milkfish)",             // string
  amount: "500g",                        // string
  productId: "product-uuid",            // string | null — optional link to buyable product
  sortOrder: 1                          // number
}
```

> [!TIP]
> When `productId` is set, the recipe detail screen can show a **"Buy This Ingredient"** button that adds the product directly to the cart. Powerful cross-sell feature.

---

### 10. `promos` — Vendor Promotions

```
promos/{promoId}
```

```javascript
{
  stallId: "stall-uuid",                 // string
  stallName: "Juan's Fresh Catch",       // string — denormalized
  title: "Fresh Catch Friday!",         // string
  description: "20% off all seafood",   // string | null
  imageUrl: "https://...",               // string | null
  discountPct: 20.0,                    // number | null
  discountAmt: null,                    // number | null
  startsAt: Timestamp,
  endsAt: Timestamp,
  isActive: true,                        // boolean
  createdAt: Timestamp
}
```

---

### 11. `inventoryAlerts` — Stock Alert History

```
inventoryAlerts/{alertId}
```

```javascript
{
  stallId: "stall-uuid",                 // string
  productId: "product-uuid",            // string
  productName: "Tilapia",               // string — denormalized
  alertType: "low_stock",               // "low_stock" | "out_of_stock"
  currentQty: 3.0,                      // number
  threshold: 5.0,                       // number
  isResolved: false,                    // boolean
  createdAt: Timestamp,
  resolvedAt: null                      // Timestamp | null
}
```

---

### 12. `paymentMethods` — Saved Payment Methods

```
users/{uid}/paymentMethods/{methodId}    ← Subcollection under users
```

```javascript
// WARNING: NEVER store raw credit card numbers or CVVs in Firebase. 
// This table only stores PayMongo Tokens to remain PCI-DSS Compliant.
{
  type: "card",                          // "gcash" | "card" | "paymaya"
  label: "Visa ending 4242",             // string — Display text
  paymongoPaymentMethodId: "pm_xyz123",  // string — The secure token from PayMongo
  brand: "visa",                         // string | null — 'visa', 'mastercard'
  lastFour: "4242",                      // string | null
  expiryMonth: 12,                       // number | null
  expiryYear: 2028,                      // number | null
  isDefault: true,                       // boolean
  createdAt: Timestamp
}
```

---

## Category-Based Filtering Logic

### The Problem (Current Implementation)
Currently, the market filter checks `vendor.category == selectedCategory`. This means a fish stall selling a meat product will **never** appear when "Meat" is selected.

### The Solution: `activeCategories` Array + `array-contains`

Firestore supports `array-contains` queries. We maintain a denormalized `activeCategories` array on each stall document:

#### Query: "Show me all stalls that sell Meat products"

```dart
// Dart / Flutter code
final stalls = await FirebaseFirestore.instance
    .collection('stalls')
    .where('activeCategories', arrayContains: 'Meat')
    .where('isOpen', isEqualTo: true)
    .orderBy('rating', descending: true)
    .get();
```

#### Query: "Show me all products" (when viewing a specific category)

```dart
// Get Meat products from a specific stall
final products = await FirebaseFirestore.instance
    .collection('products')
    .where('stallId', isEqualTo: stallId)
    .where('category', isEqualTo: 'Meat')
    .where('isAvailable', isEqualTo: true)
    .where('isDeleted', isEqualTo: false)
    .get();
```

#### Query: "Show all" (no filter)

```dart
final stalls = await FirebaseFirestore.instance
    .collection('stalls')
    .where('isOpen', isEqualTo: true)
    .orderBy('rating', descending: true)
    .get();
```

### How `activeCategories` Stays In Sync

A **Cloud Function** trigger on the `products` collection recalculates the array whenever a product is created, updated, or deleted:

```javascript
// Cloud Function (Node.js)
exports.syncStallCategories = functions.firestore
    .document('products/{productId}')
    .onWrite(async (change, context) => {
        const stallId = (change.after.data() || change.before.data()).stallId;

        // Query all active products for this stall
        const productsSnap = await admin.firestore()
            .collection('products')
            .where('stallId', '==', stallId)
            .where('isAvailable', '==', true)
            .where('isDeleted', '==', false)
            .get();

        // Extract unique categories
        const categories = [...new Set(
            productsSnap.docs.map(doc => doc.data().category)
        )];

        // Update the stall's activeCategories array
        await admin.firestore()
            .collection('stalls')
            .doc(stallId)
            .update({ activeCategories: categories });
    });
```

### How It Works In Practice

```
Scenario: "Merly Diego Dried Fish Store" (primaryCategory = 'Fish')
          adds a product "Beef Jerky" with category = 'Meat'

Cloud Function fires → stall.activeCategories becomes ["Fish", "Meat"]

Filter = 'All'        → ✅ Stall appears (all stalls shown)
Filter = 'Fish'       → ✅ Stall appears (activeCategories contains "Fish")
Filter = 'Meat'       → ✅ Stall appears (activeCategories contains "Meat")
Filter = 'Vegetables' → ❌ Stall hidden (activeCategories doesn't contain "Vegetables")
```

---

## Recipe Recommendation & Favorites Logic

### The Problem
Recommending recipes based on purchased products is a classic "Many-to-Many" relationship (Orders → Products → Ingredients → Recipes), which is natively difficult in a NoSQL database like Firestore that lacks `JOIN` operations.

### The Solution: "Tagging" & Live Queries

Instead of complex backend calculations, PalengkeGo uses **On-the-Fly Tagging** leveraging Firestore's `array-contains-any` query.

1. **Recipe Tags:** Every recipe document contains a `keyIngredients` array (e.g., `["bangus", "milkfish", "tamarind"]`).
2. **Purchase Extraction:** When a user buys items (or views their cart), the app extracts the top keywords from those products (e.g., "Bangus", "Pork").
3. **Live Query:** The app queries Firestore in real-time:
   ```dart
   // "Give me up to 5 recipes that use ANY of these recently purchased ingredients"
   FirebaseFirestore.instance.collection('recipes')
       .where('keyIngredients', arrayContainsAny: ['bangus', 'pork'])
       .limit(5).get();
   ```

*Note: `array-contains-any` is limited to 10 items per query in Firestore. The app must pick the top 10 most relevant/recent keywords from the user's purchases.*

### The UX Flow: "Hearting" Recipes

Because recommendations are generated **on-the-fly**, they will naturally vanish and refresh the next time the user buys different ingredients. To prevent user frustration, we employ a "Save to Cookbook" UX pattern.

1. **Dynamic Feed:** The user sees recommendations based on their current/latest purchases.
2. **The "Heart" Action:** If a user likes a recipe, they tap the "Heart" icon.
3. **Permanent Storage:** Tapping the heart writes a small document to the user's personal subcollection: `users/{uid}/favorites/{recipeId}`. 
4. **The Refresh:** When the user buys different ingredients tomorrow, the dynamic feed refreshes with new recommendations. Un-hearted recipes disappear.
5. **Saved Forever:** The hearted recipes are permanently saved in the user's "Saved Recipes" tab (which simply queries their `favorites` subcollection). They remain there indefinitely until the user manually un-hearts them.

This architecture ensures the app remains lightning-fast, avoids expensive backend calculations, and provides an engaging, personalized "Cookbook" experience for the user.

### Populating the Recipe Database (Data Entry Strategy)

The `recipes` collection lives in the same Firestore database as the rest of the app, operating alongside users and stalls. To populate this database with classic Filipino dishes, there are two distinct phases:

**Phase 1 (MVP): JSON Seeding**
For the initial launch, typing recipes manually into the Firebase Console is inefficient. Instead, all recipes should be drafted into a structured `.json` file locally. A one-time script (written in Dart or Node.js) will be used to "seed" the database by reading this JSON file and instantly uploading 50+ recipes into the Firestore `recipes` collection.

**Example: `recipe_seed.json` structure**
```json
[
  {
    "title": "Sinigang na Bangus",
    "category": "Seafood",
    "description": "Classic Filipino sour soup with milkfish and vegetables.",
    "prepTime": "30 mins",
    "difficulty": "Easy",
    "imageUrl": "https://storage.googleapis.com/...",
    "servings": 4,
    "keyIngredients": ["bangus", "milkfish", "tamarind", "kangkong", "radish", "tomato"],
    "instructions": [
      "Boil water in a pot with tomatoes and onions.",
      "Add the tamarind mix and stir until dissolved.",
      "Add the bangus slices and simmer for 10 minutes.",
      "Add the vegetables (radish, eggplant, kangkong) and cook for another 5 minutes.",
      "Serve hot with rice."
    ],
    "ingredientsList": [
      { "name": "Bangus (Milkfish)", "amount": "1 whole, sliced", "sortOrder": 1 },
      { "name": "Tamarind Soup Mix", "amount": "1 packet (40g)", "sortOrder": 2 },
      { "name": "Kangkong (Water Spinach)", "amount": "1 bunch", "sortOrder": 3 }
    ]
  }
]
```

**Phase 2 (Long-term): Admin Web App**
Since the app serves a local city wet market governed by a central office, a separate **Admin Web Dashboard** is planned for the future. The market office staff will use this secure website to:
* Verify and approve new vendor registrations.
* Add, edit, and publish new community recipes.
* Upload high-quality recipe cover photos directly to Firebase Cloud Storage.

---

## PayMongo Payment Architecture

Integrating payments like GCash, Credit/Debit cards, or PayMaya requires strict adherence to security standards (PCI-DSS). **You must never store raw credit card numbers, expiry dates, or CVVs directly in Firebase.**

### How PayMongo Works with Firebase

1. **Tokenization (Client-Side):**
   When the user enters their card details into the app, those details go *directly* to PayMongo's servers. PayMongo returns a secure string called a **PaymentMethod ID** (e.g., `pm_12345`).
   
2. **Saving the Method:**
   Your app saves this secure `pm_12345` token in the `users/{uid}/paymentMethods` subcollection. You can safely store the `lastFour` digits and the `brand` (Visa/Mastercard) so the user knows which card it is, but the raw data is safely locked inside PayMongo.

3. **Processing an Order:**
   * **Step 1:** Buyer places an order in the app.
   * **Step 2:** A Firebase Cloud Function wakes up, reads the order total, and talks to PayMongo to create a **PaymentIntent**.
   * **Step 3:** PayMongo gives you a `paymentIntentId` and a `checkoutUrl`. The Cloud Function saves these to the `orders/{orderId}` document.
   * **Step 4:** If it's GCash/PayMaya, the app opens the `checkoutUrl` in a webview for the user to authorize. If it's a saved card, the Cloud Function can charge the saved `PaymentMethod ID` automatically.
   
4. **Webhooks (Updating Status):**
   When the user successfully pays via GCash, PayMongo sends a "Webhook" to your Firebase Cloud Functions. Your script receives the webhook, finds the order using the `paymentIntentId`, and changes the `paymentStatus` from `"unpaid"` to `"paid"`. This instantly triggers the vendor's app to say "Order Paid & Ready to Prepare!"

### Expanded Order Flow (With Payments)

```
Order Created 
  → Status: 'pending', paymentStatus: 'unpaid'
  
Firebase requests PaymentIntent from PayMongo 
  → Order updated with checkoutUrl
  
User completes GCash payment 
  → PayMongo sends Webhook
  
Firebase updates Order 
  → Status: 'confirmed', paymentStatus: 'paid'
```

### The PayMongo Webhook JSON Payload

When a user completes their GCash payment, PayMongo sends a JSON payload (Webhook) directly to your Firebase Cloud Function. It looks exactly like this. Notice the `metadata` block—this is how we safely link the PayMongo payment back to the specific Firestore Order!

```json
{
  "data": {
    "id": "evt_123456789",
    "type": "event",
    "attributes": {
      "type": "payment.paid",
      "livemode": false,
      "data": {
        "id": "pay_98765xyz",
        "type": "payment",
        "attributes": {
          "amount": 45000,           // Note: PayMongo uses centavos (45000 = ₱450.00)
          "currency": "PHP",
          "status": "paid",
          "source": {
            "id": "src_55555abc",
            "type": "gcash"
          },
          "metadata": {
            // We pass the Firebase orderId when creating the payment intent
            // so we know exactly which order to update when this webhook fires!
            "orderId": "order-uuid-from-firebase",
            "buyerId": "firebase-auth-uid"
          }
        }
      }
    }
  }
}
```

---

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ─── Helper Functions ─────────────────────────────────────
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(uid) {
      return request.auth.uid == uid;
    }

    function isStallOwner(stallId) {
      return isAuthenticated() &&
        get(/databases/$(database)/documents/stalls/$(stallId)).data.ownerId == request.auth.uid;
    }

    // ─── Users (Buyer Profiles) ──────────────────────────────
    match /users/{uid} {
      allow read: if isAuthenticated();
      allow create: if isOwner(uid);
      allow update: if isOwner(uid);

      match /addresses/{addressId} {
        allow read, write: if isOwner(uid);
      }

      match /favorites/{recipeId} {
        allow read, write: if isOwner(uid);
      }

      match /paymentMethods/{methodId} {
        allow read, write: if isOwner(uid);
      }
    }

    // ─── Stalls ──────────────────────────────────────────────
    match /stalls/{stallId} {
      allow read: if true;  // Public — buyers browse stalls
      allow create: if isAuthenticated();
      allow update: if isStallOwner(stallId);
      allow delete: if false;  // Never delete stalls

      match /operatingHours/{day} {
        allow read: if true;
        allow write: if isStallOwner(stallId);
      }
    }

    // ─── Products ────────────────────────────────────────────
    match /products/{productId} {
      allow read: if true;  // Public — buyers browse products
      allow create: if isAuthenticated() && isStallOwner(request.resource.data.stallId);
      allow update: if isAuthenticated() && isStallOwner(resource.data.stallId);
      allow delete: if false;  // Use soft delete (isDeleted = true)
    }

    // ─── Categories ──────────────────────────────────────────
    match /categories/{categoryId} {
      allow read: if true;   // Public reference data
      allow write: if false; // Admin-only (use Firebase console or Cloud Functions)
    }

    // ─── Orders ──────────────────────────────────────────────
    match /orders/{orderId} {
      allow read: if isAuthenticated() &&
        (resource.data.buyerId == request.auth.uid ||
         isStallOwner(resource.data.stallId));
      allow create: if isAuthenticated() &&
        request.resource.data.buyerId == request.auth.uid;
      allow update: if isAuthenticated() &&
        (resource.data.buyerId == request.auth.uid ||
         isStallOwner(resource.data.stallId));
      allow delete: if false;

      match /items/{itemId} {
        allow read: if isAuthenticated() &&
          (get(/databases/$(database)/documents/orders/$(orderId)).data.buyerId == request.auth.uid ||
           isStallOwner(get(/databases/$(database)/documents/orders/$(orderId)).data.stallId));
        allow create: if isAuthenticated();
        allow update, delete: if false;  // Order items are immutable
      }
    }

    // ─── Carts ───────────────────────────────────────────────
    match /carts/{uid} {
      allow read, write: if isOwner(uid);

      match /items/{itemId} {
        allow read, write: if isOwner(uid);
      }
    }

    // ─── Reviews ─────────────────────────────────────────────
    match /reviews/{reviewId} {
      allow read: if true;   // Public — anyone can read reviews
      allow create: if isAuthenticated() &&
        request.resource.data.buyerId == request.auth.uid;
      allow update: if isAuthenticated() &&
        resource.data.buyerId == request.auth.uid;
      allow delete: if false;
    }

    // ─── Notifications ───────────────────────────────────────
    match /notifications/{notificationId} {
      allow read: if isAuthenticated() &&
        resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() &&
        resource.data.userId == request.auth.uid;
      allow create: if false;  // Only Cloud Functions create notifications
      allow delete: if isAuthenticated() &&
        resource.data.userId == request.auth.uid;
    }

    // ─── Recipes ─────────────────────────────────────────────
    match /recipes/{recipeId} {
      allow read: if true;   // Public
      allow write: if false; // Admin-only

      match /ingredients/{ingredientId} {
        allow read: if true;
        allow write: if false;
      }
    }

    // ─── Promos ──────────────────────────────────────────────
    match /promos/{promoId} {
      allow read: if true;   // Public
      allow create, update: if isAuthenticated() &&
        isStallOwner(request.resource.data.stallId);
      allow delete: if false;
    }

    // ─── Inventory Alerts ────────────────────────────────────
    match /inventoryAlerts/{alertId} {
      allow read: if isAuthenticated() &&
        isStallOwner(resource.data.stallId);
      allow create: if false;  // Cloud Functions only
      allow update: if isAuthenticated() &&
        isStallOwner(resource.data.stallId);
      allow delete: if false;
    }
  }
}
```

---

## Cloud Storage Structure

```
firebase-storage/
├── avatars/
│   └── {uid}/
│       └── profile.jpg                  ← User profile photos
├── stalls/
│   └── {stallId}/
│       ├── banner.jpg                   ← Stall banner photo
│       └── avatar.jpg                   ← Stall logo
├── products/
│   └── {stallId}/
│       └── {productId}.jpg              ← Product photos
├── promos/
│   └── {stallId}/
│       └── {promoId}.jpg                ← Promo banner images
└── recipes/
    └── {recipeId}.jpg                   ← Recipe cover images
```

### Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User avatars — owner read/write
    match /avatars/{uid}/{file} {
      allow read: if true;
      allow write: if request.auth.uid == uid
        && request.resource.size < 5 * 1024 * 1024  // Max 5MB
        && request.resource.contentType.matches('image/.*');
    }

    // Stall images — public read, owner write
    match /stalls/{stallId}/{file} {
      allow read: if true;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024;
    }

    // Product images — public read, stall owner write
    match /products/{stallId}/{file} {
      allow read: if true;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024;
    }

    // Recipe & promo images — public read
    match /recipes/{file} {
      allow read: if true;
      allow write: if false;  // Admin only
    }

    match /promos/{stallId}/{file} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## Composite Indexes

Firestore requires composite indexes for queries with multiple `where` clauses or `where` + `orderBy` on different fields.

```
Collection: stalls
Fields: activeCategories (Array), isOpen (Ascending), rating (Descending)
Query: Category filter + open stalls sorted by rating

Collection: products
Fields: stallId (Ascending), category (Ascending), isAvailable (Ascending), isDeleted (Ascending)
Query: Products for a specific stall filtered by category

Collection: products
Fields: category (Ascending), isAvailable (Ascending), isDeleted (Ascending), price (Ascending)
Query: All products in a category sorted by price

Collection: orders
Fields: buyerId (Ascending), placedAt (Descending)
Query: Buyer's order history sorted by date

Collection: orders
Fields: stallId (Ascending), status (Ascending), placedAt (Descending)
Query: Vendor's active orders sorted by date

Collection: notifications
Fields: userId (Ascending), isRead (Ascending), createdAt (Descending)
Query: User's unread notifications, newest first

Collection: reviews
Fields: stallId (Ascending), createdAt (Descending)
Query: Reviews for a stall sorted by date

Collection: promos
Fields: isActive (Ascending), endsAt (Ascending)
Query: Active promos that haven't expired
```

---

## Denormalization Strategy

### What Gets Duplicated & When to Update

| Source | Duplicated To | Trigger to Sync |
|--------|--------------|-----------------|
| `stalls.name` | `products.stallName` | Cloud Function on `stalls` update |
| `stalls.imageUrl` | `products.stallImageUrl` | Cloud Function on `stalls` update |
| `stalls.isOpen` | `products.stallIsOpen` | Cloud Function on `stalls` update |
| `products.category` | `stalls.activeCategories` | Cloud Function on `products` write |
| `products.*` | `carts/*/items.*` | Validate at checkout (lazy sync) |
| `products.*` | `orders/*/items.*` | **Never update** — these are permanent snapshots |
| `users.displayName` | `orders.buyerName` | Cloud Function on `users` update (rare) |
| `stalls.name` | `orders.stallName` | **Never update** — snapshot at order time |

### Cloud Functions Summary

| Function | Trigger | Purpose |
|----------|---------|---------|
| `syncStallCategories` | `products` onWrite | Recalculate `stalls.activeCategories` |
| `syncStallInfoToProducts` | `stalls` onUpdate | Update denormalized stall fields in products |
| `updateStallRating` | `reviews` onCreate | Recalculate `stalls.rating` and `reviewCount` |
| `createOrderNotification` | `orders` onCreate | Send notification to vendor |
| `updateOrderNotification` | `orders` onUpdate (status) | Send notification to buyer |
| `checkInventoryAlert` | `products` onUpdate (stockQty) | Create alert if below threshold |
| `incrementStallStats` | `orders` onUpdate (completed) | Increment `totalOrders`, `totalEarnings` |

---

## Mapping: Current Domain Models → Firestore Collections

| Current Dart Model | Firestore Collection | Notes |
|-------------------|---------------------|-------|
| `AppUser` | Firebase Auth + `users/` | Auth handles login; `users/` stores profile |
| `CustomerProfile` | `users/{uid}` + `users/{uid}/addresses` | Addresses split to subcollection |
| `VendorProfile` | `stalls/{stallId}` | Renamed for clarity; `ownerId` links to auth |
| `MarketVendor` | `stalls/{stallId}` (read) | Same collection, buyer-facing read query |
| `VendorProduct` | `products/{productId}` | Added `category`, `stockQty`, denormalized stall info |
| `MarketProduct` | `products/{productId}` (read) | Same collection, buyer-facing read query |
| `CartItem` | `carts/{uid}/items/{itemId}` | Server-side cart with denormalized product info |
| `MarketOrder` | `orders/{orderId}` | Denormalized buyer + stall info |
| `OrderLineItem` | `orders/{orderId}/items/{itemId}` | Snapshot fields for historical accuracy |
| `OrderStatus` | `orders.status` field | String enum on the order document |
| `Recipe` | `recipes/{recipeId}` + `/ingredients` subcollection | Normalized ingredients with product cross-links |
