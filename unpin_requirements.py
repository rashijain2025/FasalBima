import re

for file in [r"c:\Users\dell\CROPIC-AI\ML_Backend\requirements.txt", r"c:\Users\dell\CROPIC-AI\app_backend\requirements.txt"]:
    with open(file, "r") as f:
        content = f.read()
    
    new_content = re.sub(r'==[0-9a-zA-Z\.\+]+', '', content)
    
    with open(file, "w") as f:
        f.write(new_content)
