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

// 횂쨉횂짜??횄흸횄��┚꺜띊궰봤궰�??횄흸횂쩍횂쨘 횂쩔횂짭횂째횄징 횄�녍궰�??횄탐
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

// ?혻���?혻혖 ?흸흸?혶쩌 ?혻흹챗쨀쨉챙혶��� ?흹���?��◑� 챘짱쨍챘��쑣�?��봔�?��벬� 챙쨋��씳�??
app.use(express.static('public'));

// API ?혶쩌?큄째?힋쨍
app.use('/api/auth', authRoutes);

// 챘짙짢챠힋쨍 챗짼쩍챘징흹 ?��◈�?��쑣�?타짭 챙쨋��씳�??
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

const PORT = process.env.PORT || 3000;

// ?혥째?혶쨈?��왖걘ヂ꼲졗�혶쨈?힋짚 ?��붋걘ぢ�? ?�꽓���?혶쨍
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
app.use(express.json()); // JSON 횉체쩍횆��횉 쩔채횄쨩��쨩 횄쨀쨍짰횉횘 쩌철 ��횜쨉쨉쨌횕 쩌쨀횁짚

// Static folder to serve the HTML file
app.use(express.static('public'));

// 쨌횓짹횞��횓 API 쨋처쩔챙횈짰
app.use('/api/auth', authRoutes);

app.use((req, res, next) => {
    res.setHeader('Content-Type', 'text/html; charset=UTF-8');
    next();
});

// 짹창쨘쨩 HTML 횈횆��횕 횁짝째첩
app.get('/', (req, res) => {
    res.setHeader('Content-Type', 'text/html; charset=UTF-8');
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});
app.get('/dashboard', (req, res) => {
    res.send('Hello World'); // 대시보드 페이지에 "Hello World" 출력
});

const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});
