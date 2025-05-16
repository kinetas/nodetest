import json
import pandas as pd # type: ignore
from sklearn.ensemble import IsolationForest # type: ignore

with open("user_actions.log") as f:
    logs = [json.loads(line) for line in f]

df = pd.DataFrame(logs)
df['timestamp'] = pd.to_datetime(df['timestamp'])

# 사용자별 행동 특성 요약
features = df.groupby('userId').apply(lambda g: pd.Series({
    "action_count": len(g),
    "avg_interval": g['timestamp'].diff().dt.total_seconds().mean() or 0,
    "unique_ips": g['ip'].nunique(),
    "ua_variety": g['ua'].nunique()
})).fillna(0).reset_index()

# 이상 탐지
model = IsolationForest(contamination=0.2)
features['is_bot'] = model.fit_predict(features.drop(columns='userId'))

# 룰 기반: avg_interval이 3초 미만이면 봇으로 간주
features['rule_based_bot'] = features['avg_interval'] < 3.0

# 모델과 수동 조건 중 하나라도 만족하면 is_bot_final = -1 (이상 사용자)
features['is_bot_final'] = features.apply(
    lambda row: -1 if (row['is_bot'] == -1 or row['rule_based_bot']) else 1,
    axis=1
)

# 결과 확인
print(features.sort_values('is_bot_final'))