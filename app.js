/*
const express = require('express');
const dotenv = require('dotenv');
const sequelize = require('./config/db');
const authRoutes = require('./routes/authRoutes');

dotenv.config();

const app = express();
app.use(express.json());

app.use('/api/auth', authRoutes);

const PORT = process.env.PORT || 3000;

// ÂµÂ¥??ÃŒÃ…ÃÂºÂ£??ÃŒÂ½Âº Â¿Â¬Â°Ã¡ ÃˆÂ®??ÃŽ
sequelize.authenticate()
    .then(() => {
        console.log('Database connected...');
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });
    })
    .catch(err => {
        console.error('Unable to connect to the database:', err);
    });*/
//==================================================================
/*
const express = require('express');
const dotenv = require('dotenv');
const path = require('path');
const sequelize = require('./config/db');
const authRoutes = require('./routes/authRoutes');

dotenv.config();

const app = express();
app.use(express.json());

// ? •?  ?ŒŒ?¼ ? œê³µì„ ?œ„?•œ ë¯¸ë“¤?›¨?–´ ì¶”ê??
app.use(express.static('public'));

// API ?¼?š°?Š¸
app.use('/api/auth', authRoutes);

// ë£¨íŠ¸ ê²½ë¡œ ?•¸?“¤?Ÿ¬ ì¶”ê??
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

const PORT = process.env.PORT || 3000;

// ?°?´?„°ë² ì´?Š¤ ?—°ê²? ?™•?¸
sequelize.authenticate()
    .then(() => {
        console.log('Database connected...');
        app.listen(PORT,'0.0.0.0', () => {
            console.log(`Server running on port ${PORT}`);
        });
    })
    .catch(err => {
        console.error('Unable to connect to the database:', err);
    });
======================================*/
const express = require('express');
const path = require('path');
const authRoutes = require('./routes/authRoutes');

const app = express();
app.use(express.json()); // JSON Çü½ÄÀÇ ¿äÃ»À» Ã³¸®ÇÒ ¼ö ÀÖµµ·Ï ¼³Á¤

// Static folder to serve the HTML file
app.use(express.static('public'));

// ·Î±×ÀÎ API ¶ó¿ìÆ®
app.use('/api/auth', authRoutes);

// ±âº» HTML ÆÄÀÏ Á¦°ø
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});
