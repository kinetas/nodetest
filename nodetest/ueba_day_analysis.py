import json
import pandas as pd
from sklearn.ensemble import IsolationForest

with open("logs/user_actions.log") as f:
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

# 결과 확인
print(features.sort_values('is_bot'))