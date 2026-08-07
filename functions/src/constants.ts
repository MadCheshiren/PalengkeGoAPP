/**
 * Shared domain constants for the trusted backend.
 *
 * These mirror the Flutter-side enums (OrderStatus, PaymentStatus,
 * FeeConfig.cancelWindow = 5 min) so both sides agree on the same graph.
 */

export const CANCELLATION_WINDOW_MS = 5 * 60 * 1000; // mirrors FeeConfig.cancelWindow

export type OrderStatus =
  | 'pending'
  | 'confirmed'
  | 'preparing'
  | 'ready'
  | 'completed'
  | 'cancelled'
  | 'rejected';

export const TERMINAL_STATUSES: ReadonlySet<OrderStatus> = new Set([
  'completed',
  'cancelled',
  'rejected',
]);

const TRANSITIONS: Record<OrderStatus, ReadonlySet<OrderStatus>> = {
  pending: new Set(['confirmed', 'preparing', 'rejected', 'cancelled']),
  confirmed: new Set(['preparing', 'cancelled']),
  preparing: new Set(['ready', 'cancelled']),
  ready: new Set(['completed']),
  completed: new Set(),
  cancelled: new Set(),
  rejected: new Set(),
};

export function canTransition(
  from: OrderStatus,
  to: OrderStatus,
): boolean {
  return TRANSITIONS[from].has(to);
}

export interface OrderItemInput {
  productId: string;
  quantity: number;
  unit?: string;
}