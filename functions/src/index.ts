import * as admin from 'firebase-admin';

admin.initializeApp();

export { placeOrder, updateOrderStatus, cancelOrder } from './orders';
export { addReview } from './reviews';
export { getSalesReport } from './reports';
export { onOrderCompleted } from './sales';