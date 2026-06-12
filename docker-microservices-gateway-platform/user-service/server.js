const express = require('express');

const app = express();
const port = process.env.PORT || 3001;

app.use(express.json());

let users = [
  { id: 1, name: 'Ada Lovelace', email: 'ada@example.com' },
  { id: 2, name: 'Alan Turing', email: 'alan@example.com' }
];

let nextId = 3;

app.get('/health', (req, res) => {
  res.status(200).json({
    service: 'user-service',
    status: 'healthy'
  });
});

app.get('/users', (req, res) => {
  res.status(200).json(users);
});

app.get('/users/:id', (req, res) => {
  const user = users.find(item => item.id === Number(req.params.id));

  if (!user) {
    return res.status(404).json({
      error: 'User not found',
      message: `No user exists with id ${req.params.id}`
    });
  }

  res.status(200).json(user);
});

app.post('/users', (req, res) => {
  const { name, email } = req.body;

  if (!name || !email) {
    return res.status(400).json({
      error: 'Invalid user payload',
      message: 'name and email are required'
    });
  }

  const user = {
    id: nextId++,
    name,
    email
  };

  users.push(user);

  res.status(201).json(user);
});

app.listen(port, () => {
  console.log(`user-service listening on port ${port}`);
});
