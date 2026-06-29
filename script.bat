@echo off
echo =======================================
echo Auto Pushing to GitHub...
echo =======================================
git add .
git commit -m "Auto push from script"
git push
echo =======================================
echo Done!
echo =======================================
pause
