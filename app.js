const express = require('express');
const session = require('express-session'); //ï¿½ê½­ï¿½ë?¡ç•°ë¶½ï¿½ï¿?
const cron = require('node-cron');
const path = require('path');
const authRoutes = require('./routes/authRoutes'); // ï¿½ì”ªï¿½ìŠ¦ï¿½ë“ƒ åª›ï¿½ï¿½ì¡‡ï¿½ì‚¤æ¹²ï¿½
const missionRoutes = require('./routes/missionRoutes'); // èª˜ëª„??? ï¿½ì”ªï¿½ìŠ¦ï¿½ë“ƒ ?º?ˆ?œ­ï¿½ì‚¤æ¹²ï¿½
const roomRoutes = require('./routes/roomRoutes');
const friendRoutes = require('./routes/friendRoutes');
const cVoteRoutes = require('./routes/cVoteRoutes');
const c_missionRoutes = require('./routes/c_missionRoutes');
const resultRoutes = require('./routes/resultRoutes'); // ê²°ê³¼ ?¼?š°?Š¸ ì¶”ê??
const { checkMissionStatus } = require('./controllers/c_missionController');
const { checkMissionDeadline } = require('./controllers/missionController');
const db = require('./config/db');
const app = express();
const PORT = 3000;

// // ======== ?ˆ˜? • JWT ============
const jwt = require('jsonwebtoken'); // JWT ì¶”ê??
// const requireAuth = require('./middleware/authMiddleware');

const cors = require('cors');
app.use(cors());  // ëª¨ë“  ì¶œì²˜?˜ ?š”ì²??„ ?—ˆ?š©

app.use(express.json()); // JSON ï¿½ë™†ï¿½ë–›ï¿½ì“£ ï¿½ìžï¿½ë¸³ èª˜ëªƒë±¾ï¿½?¾ï¿½ë¼± ï¿½ê½•ï¿½ì ™
app.use(express.urlencoded({ extended: true })); // URL ï¿½ì”¤?‚„ë¶¾ëµ«ï¿½ë§‚ ï¿½ëœ²ï¿½ì” ï¿½ê½£ ï¿½ë™†ï¿½ë–›ï¿½ì“£ ï¿½ìžï¿½ë¸³ èª˜ëªƒë±¾ï¿½?¾ï¿½ë¼± ï¿½ê½•ï¿½ì ™

// ï¿½ê½­ï¿½ë?? ï¿½ê½•ï¿½ì ™
app.use(session({
    secret: 'your_secret_key', // ï¿½ê½­ï¿½ë?? ï¿½ë¸«ï¿½ìƒ‡ï¿½ì†•ï¿½ë¿‰ ï¿½ê¶—ï¿½ìŠœï¿½ë¸· ï¿½ê¶Ž
    resave: false, // ï¿½ê½­ï¿½ë?¡ï¿½?“£ ï¿½ë¹†ï¿½ê¸½ ï¿½ï¿½ï¿½ï¿½?˜£ï¿½ë¸·ï§žï¿½ ï¿½ë¿¬?ºï¿?
    saveUninitialized: false, // ?¥?‡ë¦°ï¿½?†•ï¿½ë¦ºï§žï¿½ ï¿½ë¸¡ï¿½ï¿½ï¿? ï¿½ê½­ï¿½ë?¡ï¿½?“£ ï¿½ï¿½ï¿½ï¿½?˜£ï¿½ë¸·ï§žï¿½ ï¿½ë¿¬?ºï¿?
    cookie: { maxAge: 24 * 60 * 60 * 1000 } // ?‘ì¢ê¶Žï¿½ì“½ ï¿½ì??ï¿½ìŠš æ¹²ê³Œì»? (ï¿½ë¿¬æ¹²ê³—ê½Œï¿½?’— ï¿½ë¸¯?Œ·ï¿?)
}));

// // ======== ?ˆ˜? • JWT ============
// // JSON ?ŒŒ?‹±ê³? URL ?¸ì½”ë”© ?„¤? •
// app.use(cors());
// app.use(express.json());
// app.use(express.urlencoded({ extended: true }));

// Static folder to serve the HTML file
app.use(express.static('public'));


// ë©”ì‹œì§? ????ž¥?„ ì²˜ë¦¬?•˜?Š” API ?—”?“œ?¬?¸?Š¸ ì¶”ê??
app.post('/api/messages', (req, res) => {
    const { u1_id, u2_id, r_id, message_contents } = req.body;})
   /* // DB?— ë©”ì‹œì§? ????ž¥ ë¡œì§ ì¶”ê??
    if (!u1_id || !u2_id || !r_id || !message_contents) {
        console.error('Missing required fields:', { u1_id, u2_id, r_id, message_contents});
        return res.status(400).json({ message: '?•„?ˆ˜ ê°’ì´ ?ˆ„?½?˜?—ˆ?Šµ?‹ˆ?‹¤.' });
    }
    db.query(
        //'INSERT INTO r_message (u1_id, u2_id, r_id, message_contents, send_date) VALUES (?, ?, ?, ?, NOW())',
        'INSERT INTO r_message (u1_id, u2_id, r_id, message_contents) VALUES (?, ?, ?, ?)',
        [u1_id, u2_id, r_id, message_contents,],
        (err, result) => {
            if (err) {
                console.error('Error saving message to DB:', err);
                return res.status(500).json({ message: 'Failed to save message' });
            }

            // DB?— ?„±ê³µì ?œ¼ë¡? ????ž¥?œ ê²½ìš°
            res.json({
                //r_id: r_id,
                message_contents: message_contents,
                send_date: new Date().toISOString().slice(0, 19).replace('T', ' '),
                u1_id: u1_id,
                //u2_id: u2_id
            });
        }
    );
});
*/



// ï¿½ê½­ï¿½ë?? ï¿½ì”¤ï§ï¿½ èª˜ëªƒë±¾ï¿½?¾ï¿½ë¼±
const requireAuth = (req, res, next) => {
    if (!req.session.user) {
        return res.status(401).json({ message: 'æ¿¡ì’“? ‡ï¿½ì”¤ï¿½ì”  ï¿½ë¸˜ï¿½ìŠ‚ï¿½ë??ï¿½ë•²ï¿½ë–Ž.' });
    }
    next();
};



// ï¿½ì‚ï¿½ë–†: ï¿½ï¿½ï¿½ï¿½?–†è¹‚ë??ë±? ï¿½ì”ªï¿½ìŠ¦ï¿½ë“ƒ è¹‚ëŒ„?ƒ‡
app.get('/dashboard', requireAuth, (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
    // const userId = req.session.user.id;
    // res.json({ userId });
});
app.get('/community_missions', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'community_missions.html')); // community-missions.html ?Ž˜?´ì§? ê²½ë¡œ
});

// ï¿½ì??ï¿½ï¿½ï¿? ï¿½ì ™è¹‚ë??ï¿½ï¿½ è«›ì„‘?†šï¿½ë¸¯ï¿½ë’— ï¿½ì”ªï¿½ìŠ¦ï¿½ë“ƒ ?•°ë¶½ï¿½ï¿?
app.get('/user-info', requireAuth, (req, res) => {
    res.json({ userId: req.session.user.id });
});



// ï§žë??ê°¹å¤·?„Å HTML ï¿½ì‰±ï¿½ì‰®? ?™?˜™ï¿½ìŠƒ ï¿½ì‰§ï§žì•¹?Žï§£ï¿½
app.get('/', (req, res) => {
    res.setHeader('Content-Type', 'text/html; charset=UTF-8');
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});
app.get('/dashboard', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'dashboard.html')); // ï¿½ï¿½ï¿½ï¿½?–†è¹‚ë??ë±? HTML ï¿½ë™†ï¿½ì”ª
});
app.get('/register', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'register.html')); // ï¿½ì‰¶ï¿½ìåª›ï¿½ï¿½ì—¯ HTML ï¿½ë™†ï¿½ì”ª
});
app.get('/rooms', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'rooms.html'));
});

app.get('/findinfo', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'findinfo.html'));  //?•„?´?””/ë¹„ë??ë²ˆí˜¸ ì°¾ê¸° ?Ž˜?´ì§?
});
app.get('/cVote', requireAuth, (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'cVote.html'));
});
app.get('/chat', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'chat.html')); //ì±„íŒ… ?Ž˜?´ì§?
});

app.get('/result', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'result.html')); // result.html ê²½ë¡œ
});

app.get('/printmissionlist', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'printmissionlist.html')); // printmissionlist.html ê²½ë¡œ
});
app.get('/cVote/details/:c_number', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'voteDetails.html'));
});

app.use('/api/auth', authRoutes);

app.use('/dashboard', missionRoutes); // èª˜ëª„??? ï¿½ì”ªï¿½ìŠ¦ï¿½ë“ƒ?‘œï¿? /dashboardæ¿¡ï¿½ ï¿½ê½•ï¿½ì ™
app.use('/api/rooms', roomRoutes);

app.use('/api/missions', missionRoutes); // ë¯¸ì…˜ ê´?? ¨ ?¼?š°?Š¸ ?“±ë¡?

app.use('/result', resultRoutes); // '/result' ê²½ë¡œ?— ?¼?š°?Š¸ ?—°ê²?

// ì¹œêµ¬ ë¦¬ìŠ¤?Š¸ ?¼?š°?Š¸ ì¶”ê??
app.use('/dashboard/friends', friendRoutes);
app.use('/api/cVote', cVoteRoutes);
app.use('/api/comumunity_missions', c_missionRoutes);
cron.schedule('0 0 * * *', () => {
    console.log('ë¯¸ì…˜ ?ƒ?ƒœ ?™•?¸ ë°? ì²˜ë¦¬ ?‹œ?ž‘');
    checkMissionStatus();
});



// ë¯¸ì…˜ ë§ˆê°ê¸°í•œ ?™•?¸
// cron.schedule('* * * * *', () => { // ë§¤ì¼ ?ž? • ?‹¤?–‰
cron.schedule('0 0 * * *', () => { // ë§¤ì¼ ?ž? • ?‹¤?–‰
    console.log('ë§ˆê° ê¸°í•œ ?™•?¸ ?ž‘?—… ?‹œ?ž‘');
    checkMissionDeadline();
});

// // ======== ?ˆ˜? • JWT ============
// // JWT ?¸ì¦? ë¯¸ë“¤?›¨?–´ë¡? ë³´í˜¸?œ ?¼?š°?Š¸
// app.use('/dashboard', require('./middleware/authMiddleware'), missionRoutes);
// app.use('/api/rooms', require('./middleware/authMiddleware'), roomRoutes);
// app.use('/api/cVote', require('./middleware/authMiddleware'), cVoteRoutes);

app.use((req, res) => {
    res.status(404).send('404 Not Found');
});


app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});