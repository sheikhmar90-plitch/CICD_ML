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
	# Naye hf tool se direct login bina kisi error ke
	hf auth login --token $(HF)

push-hub:
	# Naye hf upload format ke sath folders ko direct Hugging Face par bhej rahe hain
	hf upload sheikhmar90-plitch/my-model-app ./App . --repo-type=space --commit-message="Sync App files" || hf upload sheikhmar90/my-model-app ./App . --repo-type=space --commit-message="Sync App files"
	hf upload sheikhmar90-plitch/my-model-app ./Model ./Model --repo-type=space --commit-message="Sync Model" || hf upload sheikhmar90/my-model-app ./Model ./Model --repo-type=space --commit-message="Sync Model"
	hf upload sheikhmar90-plitch/my-model-app ./Results ./Metrics --repo-type=space --commit-message="Sync Metrics" || hf upload sheikhmar90/my-model-app ./Results ./Metrics --repo-type=space --commit-message="Sync Metrics"

deploy: hf-login push-hub
