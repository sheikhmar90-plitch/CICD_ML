install:
	pip install --upgrade pip
	pip install -r requirements.txt

format:
	black *.py

train:
	python train.py

eval:
	echo "## Model Metrics" > report.md
	cat Results/metrics.txt >> report.md
	echo "" >> report.md
	echo "## Confusion Matrix Plot" >> report.md
	echo "![Confusion Matrix](Results/model_results.png)" >> report.md
	cat report.md >> $(GITHUB_STEP_SUMMARY)

USER_NAME ?= "CI Bot"
USER_EMAIL ?= "bot@example.com"

update-branch:
	git config --global user.name "$(USER_NAME)"
	git config --global user.email "$(USER_EMAIL)"
	git add .
	git commit -m "Update with new results" || true
	git push --force origin HEAD:update

