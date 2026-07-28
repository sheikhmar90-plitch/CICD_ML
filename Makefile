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
	git commit -am "Update with new results"
	git push --force origin HEAD:update

hf-login:
	git pull origin update || true
	pip install -U huggingface_hub
	huggingface-cli login --token $(HF) --add-to-git-credential

push-hub:
	huggingface-cli upload systembae/my-model-app ./App . --repo-type=space --commit-message="Sync App files"
	huggingface-cli upload systembae/my-model-app ./Model ./Model --repo-type=space --commit-message="Sync Model"
	huggingface-cli upload systembae/my-model-app ./Results ./Metrics --repo-type=space --commit-message="Sync Metrics"

deploy: hf-login push-hub
