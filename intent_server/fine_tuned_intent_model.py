from datasets import load_dataset, DatasetDict
from transformers import AutoTokenizer, AutoModelForSequenceClassification, TrainingArguments, Trainer
import numpy as np
import evaluate

# 🧪 데이터 로드 (CSV or JSONL 선택)
dataset = load_dataset("csv", data_files="intent_data.csv")  # 또는 "csv"

# 🧠 라벨 인코딩
label_list = ["GENERAL", "SPECIFIC"]
label2id = {label: i for i, label in enumerate(label_list)}
id2label = {i: label for i, label in enumerate(label_list)}

def encode_labels(example):
    example["label"] = label2id[example["label"]]
    return example

dataset = dataset.map(encode_labels)

# ✂️ 토크나이징
model_name = "monologg/koelectra-small-v3-discriminator"
tokenizer = AutoTokenizer.from_pretrained(model_name)

def tokenize(example):
    return tokenizer(example["text"], padding="max_length", truncation=True)

dataset = dataset.map(tokenize)

# 📦 모델 로딩
model = AutoModelForSequenceClassification.from_pretrained(
    model_name,
    num_labels=len(label_list),
    id2label=id2label,
    label2id=label2id
)

# 🏋️‍♂️ Trainer 설정
training_args = TrainingArguments(
    output_dir="./intent_model",
    evaluation_strategy="epoch",
    save_strategy="epoch",
    num_train_epochs=5,
    per_device_train_batch_size=8,
    save_total_limit=1,
    load_best_model_at_end=True
)

metric = evaluate.load("accuracy")

def compute_metrics(eval_pred):
    logits, labels = eval_pred
    preds = np.argmax(logits, axis=-1)
    return metric.compute(predictions=preds, references=labels)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=dataset["train"],
    eval_dataset=dataset["train"],
    compute_metrics=compute_metrics
)

# 🚀 학습 시작
trainer.train()

# 💾 저장
trainer.save_model("./intent_model")
tokenizer.save_pretrained("./intent_model")
model.save_pretrained("./intent_model")