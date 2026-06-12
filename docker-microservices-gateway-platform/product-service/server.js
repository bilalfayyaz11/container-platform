const express = require('express');

const app = express();
const port = process.env.PORT || 3002;

app.use(express.json());

let products = [
  { id: 1, name: 'Laptop', category: 'electronics', price: 1200, stock: 10 },
  { id: 2, name: 'Keyboard', category: 'electronics', price: 80, stock: 50 },
  { id: 3, name: 'Desk Chair', category: 'office', price: 180, stock: 25 }
];

let nextId = 4;

app.get('/health', (req, res) => {
  res.status(200).json({
    service: 'product-service',
    status: 'healthy'
  });
});

app.get('/products', (req, res) => {
  const { category, minPrice, maxPrice } = req.query;

  let result = [...products];

  if (category) {
    result = result.filter(item => item.category === category);
  }

  if (minPrice) {
    result = result.filter(item => item.price >= Number(minPrice));
  }

  if (maxPrice) {
    result = result.filter(item => item.price <= Number(maxPrice));
  }

  res.status(200).json(result);
});

app.get('/products/:id', (req, res) => {
  const product = products.find(item => item.id === Number(req.params.id));

  if (!product) {
    return res.status(404).json({
      error: 'Product not found',
      message: `No product exists with id ${req.params.id}`
    });
  }

  res.status(200).json(product);
});

app.post('/products', (req, res) => {
  const { name, category, price, stock } = req.body;

  if (!name || !category || price === undefined || stock === undefined) {
    return res.status(400).json({
      error: 'Invalid product payload',
      message: 'name, category, price, and stock are required'
    });
  }

  const product = {
    id: nextId++,
    name,
    category,
    price: Number(price),
    stock: Number(stock)
  };

  products.push(product);

  res.status(201).json(product);
});

app.patch('/products/:id/stock', (req, res) => {
  const product = products.find(item => item.id === Number(req.params.id));

  if (!product) {
    return res.status(404).json({
      error: 'Product not found',
      message: `No product exists with id ${req.params.id}`
    });
  }

  if (req.body.stock === undefined) {
    return res.status(400).json({
      error: 'Invalid stock payload',
      message: 'stock is required'
    });
  }

  product.stock = Number(req.body.stock);

  res.status(200).json(product);
});

app.listen(port, () => {
  console.log(`product-service listening on port ${port}`);
});
