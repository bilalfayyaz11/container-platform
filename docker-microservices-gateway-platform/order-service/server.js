const express = require('express');

const app = express();
const port = process.env.PORT || 3003;

const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://user-service:3001';
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://product-service:3002';

app.use(express.json());

let orders = [];
let nextId = 1;

const validStatuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];

async function fetchJson(url) {
  const response = await fetch(url, {
    signal: AbortSignal.timeout(3000)
  });

  const data = await response.json();

  return {
    ok: response.ok,
    status: response.status,
    data
  };
}

app.get('/health', (req, res) => {
  res.status(200).json({
    service: 'order-service',
    status: 'healthy'
  });
});

app.get('/orders', (req, res) => {
  res.status(200).json(orders);
});

app.get('/orders/:id', (req, res) => {
  const order = orders.find(item => item.id === Number(req.params.id));

  if (!order) {
    return res.status(404).json({
      error: 'Order not found',
      message: `No order exists with id ${req.params.id}`
    });
  }

  res.status(200).json(order);
});

app.get('/orders/user/:userId', (req, res) => {
  const userOrders = orders.filter(item => item.userId === Number(req.params.userId));
  res.status(200).json(userOrders);
});

app.post('/orders', async (req, res) => {
  const { userId, items } = req.body;

  if (!userId || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({
      error: 'Invalid order payload',
      message: 'userId and at least one order item are required'
    });
  }

  let userValidation = {
    checked: false,
    available: false,
    warning: null,
    user: null
  };

  try {
    const userResult = await fetchJson(`${USER_SERVICE_URL}/users/${userId}`);
    userValidation.checked = true;

    if (!userResult.ok) {
      return res.status(404).json({
        error: 'User validation failed',
        message: `User ${userId} does not exist`
      });
    }

    userValidation.available = true;
    userValidation.user = userResult.data;
  } catch (error) {
    userValidation.warning = 'User service unreachable. Order accepted with degraded validation.';
  }

  let enrichedItems = [];
  let total = 0;

  for (const item of items) {
    if (!item.productId || !item.quantity || item.quantity <= 0) {
      return res.status(400).json({
        error: 'Invalid order item',
        message: 'Each item requires productId and positive quantity'
      });
    }

    let productResult;

    try {
      productResult = await fetchJson(`${PRODUCT_SERVICE_URL}/products/${item.productId}`);
    } catch (error) {
      return res.status(503).json({
        error: 'Product service unavailable',
        message: 'Unable to fetch product pricing. Order was not created.'
      });
    }

    if (!productResult.ok) {
      return res.status(404).json({
        error: 'Product validation failed',
        message: `Product ${item.productId} does not exist`
      });
    }

    const product = productResult.data;
    const lineTotal = product.price * item.quantity;

    enrichedItems.push({
      productId: product.id,
      productName: product.name,
      unitPrice: product.price,
      quantity: item.quantity,
      lineTotal
    });

    total += lineTotal;
  }

  const order = {
    id: nextId++,
    userId: Number(userId),
    status: 'pending',
    items: enrichedItems,
    total,
    validation: userValidation,
    createdAt: new Date().toISOString()
  };

  orders.push(order);

  res.status(201).json(order);
});

app.patch('/orders/:id/status', (req, res) => {
  const order = orders.find(item => item.id === Number(req.params.id));

  if (!order) {
    return res.status(404).json({
      error: 'Order not found',
      message: `No order exists with id ${req.params.id}`
    });
  }

  const { status } = req.body;

  if (!validStatuses.includes(status)) {
    return res.status(400).json({
      error: 'Invalid order status',
      message: `status must be one of: ${validStatuses.join(', ')}`
    });
  }

  order.status = status;
  order.updatedAt = new Date().toISOString();

  res.status(200).json(order);
});

app.listen(port, () => {
  console.log(`order-service listening on port ${port}`);
});
