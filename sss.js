const express = require('express');
const bodyParser = require('body-parser');

const app = express();

// JSON 데이터를 처리할 수 있도록 설정
app.use(bodyParser.json());

// POST 요청을 처리하는 엔드포인트
app.post('/', (req, res) => {
  const { value } = req.body;  // 클라이언트에서 보낸 데이터 가져오기
  console.log('서버로 받은 값:', value);

  if (value === 1) {
    res.status(200).send('서버에서 받은 값: 1');
  } else {
    res.status(400).send('잘못된 값');
  }
});

// 서버 포트 3000에서 실행
app.listen(3000, () => {
  console.log('서버가 3000번 포트에서 실행 중...');
});