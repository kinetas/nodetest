from locust import HttpUser, task, between

class KeycloakLoginTest(HttpUser):
    wait_time = between(0.5, 1.0)

    @task
    def login(self):
        payload = {
            "username": "testuser",  # 실제 테스트 계정
            "password": "testpassword"
        }
        self.client.post("/auth/keycloak-direct-login", json=payload)