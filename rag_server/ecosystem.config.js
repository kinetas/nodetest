module.exports = {
    apps: [
      {
        name: "main-rag",
        script: "main.py",
        interpreter: "python3",
        args: "",
      },
      {
        name: "intent-classifier",
        script: "intent_classifier.py",
        interpreter: "python3",
        args: "",
      }
    ]
  }
  