const express = require('express');
const path = require('path');
const fileUpload = require('express-fileupload');
const userRoutes = require('./routes/users');
const paymentRoutes = require('./routes/payments');
const searchRoutes = require('./routes/search');
const fileRoutes = require('./routes/files');
const profileRoutes = require('./routes/profile');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(fileUpload());
app.use(express.static(path.join(__dirname, 'public')));

// View engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Routes
app.use('/api/users', userRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/search', searchRoutes);
app.use('/files', fileRoutes);
app.use('/profile', profileRoutes);

// Home page
app.get('/', (req, res) => {
  res.render('index');
});

// Registration page
app.get('/register', (req, res) => {
  res.render('register');
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`QA Demo App running on http://localhost:${PORT}`);
  });
}

module.exports = app;
