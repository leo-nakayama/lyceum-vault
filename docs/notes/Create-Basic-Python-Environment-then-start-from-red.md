# Create Basic Python Environment (then start from red)

A basic Python envivonment setup using `venv`, `pip`, `ruff`, `mypy`, and `pytest`.

## Start with creating a new venv folder

```text
mkdir test
cd test/
python3 -m venv .venv
source .venv/bin/activate
```

The begining of the prompt line shows (<VENV_DIR_NAME>) to indicate the venv is active. 

```text
(.venv) ⚙leo@g16:~/Projects/test$
```

Notice that this perenthesis with <VENV_DIR_NAME> inside does not gurantee the venv is working as ecpected. For example, if venv is not actually activated, the command line `python3 foo.py` can accidentally run the system wide python3 (`/usr/bin/python3 foo.py`), which is not desirable. Use `which <COMMAND>` to ensure `.venv/bin/<COMMAND>` is activated.

---

## Upgrade pip. Verify the venv is activated.

**If there is a requirement.txt**

```bash
pip install -r requirements.txt
```

(Else)

```bash
pip install --upgrade pip
which pip && which python3
# /home/leo/Projects/test/.venv/bin/pip
# /home/leo/Projects/test/.venv/bin/python3
```
---

## Install ruff, mypy, and pytest

```bash
which pip && which python3 # make sure venv is activated
```

**Only** if venv activation is verified:

```bash
pip install ruff
pip install mypy
pip install pytest
```
---

## Start coding by testing
Start by test*.py then *.py (red-green/TDD)

```text
(.venv) ⚙leo@g16:~/Projects/test$ vim test_one.py
(.venv) ⚙leo@g16:~/Projects/test$ mypy test_one.py
Success: no issues found in 1 source file
(.venv) ⚙leo@g16:~/Projects/test$ pytest -q
.                                                                       [100%]
1 passed in 0.00s

(.venv) ⚙leo@g16:~/Projects/test$ vim main.py
(.venv) ⚙leo@g16:~/Projects/test$ mypy .
Success: no issues found in 2 source files
```
---

## Freeze requirements.txt

```bash
pip freeze > requirements.txt
```
---
