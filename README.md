# Resume Grader
### Plan for execution:

Frontend: iOS app (in Swift)
* Lets the user upload their resume (as .pdf, .docx, or .txt)
* Sends that file to your Python backend using an HTTP request (e.g., POST)


Backend: Python (Flask)
* Receives the file
* Converts or processes it (e.g., using pypandoc)
* Sends the content to OpenAI for scoring or analysis
* Returns a response (like the score) back to the Swift app

Run the Flask server locally, eventually commercially? 
