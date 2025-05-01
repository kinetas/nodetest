const session = require('express-session');
const Keycloak = require('keycloak-connect');

// 메모리 세션 저장소 생성
const memoryStore = new session.MemoryStore();

// Keycloak 인스턴스 생성
const keycloak = new Keycloak({ store: memoryStore });

module.exports = {
  keycloak,
  memoryStore
};