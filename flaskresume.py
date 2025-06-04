from flask import Flask, request, jsonify
from openai import OpenAI
import os
import pypandoc

app = Flask(__name__)
client = OpenAI()

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/upload", methods=["POST"])
def upload_resume():
    if "file" not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files["file"]
    if file.filename == "":
        return jsonify({"error": "No selected file"}), 400

    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)

    if file.filename.endswith(".docx"):
        txt_name = filepath.replace(".docx", ".txt")
        pypandoc.convert_file(filepath, 'plain', outputfile=txt_name)
        resume_text = open(txt_name, 'r').read().replace('\n', '')
    elif file.filename.endswith(".txt"):
        resume_text = open(filepath, 'r').read().replace('\n', '')
    else:
        return jsonify({"error": "Unsupported file type"}), 400

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {
                "role": "system",
                "content": "You will be provided a resume. Your task is to score this resume on a scale from 1 - 100 on how qualified they are for the job described in the following paragraph: Need a talented Java developer who can speak French. Only print out the score for how qualified the applicant is."
            },
            {
                "role": "user",
                "content": resume_text
            }
        ],
        temperature=0.7,
        max_tokens=64,
        top_p=1
    )

    score = response.choices[0].message.content.strip()
    return jsonify({"score": score})

if __name__ == "__main__":
    app.run(debug=True)
