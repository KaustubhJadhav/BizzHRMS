# Instructions to Remove Secrets from Git History

## Step 1: Install git-filter-repo
Run this command in PowerShell:
```powershell
pip install git-filter-repo
```

## Step 2: Commit Current Changes (Redacted Files)
```powershell
cd "E:\WORK\Creative Crows\BizzHRMS"
git commit -m "Security: Remove API keys from tracked files"
```

## Step 3: Clean Git History
This will replace the API keys in ALL commits with [REDACTED]:
```powershell
git filter-repo --replace-text replacements.txt
```

## Step 4: Clean Up Git References
```powershell
Remove-Item -Recurse -Force .git\refs\original -ErrorAction SilentlyContinue
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

## Step 5: Force Push to Remote (WARNING: This rewrites history!)
```powershell
git push origin --force --all
git push origin --force --tags
```

## ⚠️ IMPORTANT NOTES:
1. **Backup your repository first** - This rewrites history permanently
2. **Notify all team members** - They need to re-clone the repository after you push
3. **The replacements.txt file** will be automatically removed by git-filter-repo
4. **After pushing**, all collaborators must:
   - Delete their local repository
   - Clone fresh from remote

## Step 6: Verify Secrets Are Removed
Check that secrets are gone from history:
```powershell
git log -p --all | Select-String "AIzaSy"
```
This should return nothing if cleanup was successful.

