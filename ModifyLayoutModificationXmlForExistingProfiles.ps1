# initialize list of files to be modified, starting with the default user profile
$filesToModify = @("$Env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml")

# add locations for all existing user profiles
$childrenToOmit = @('Public','Default')
Get-ChildItem -Path "$Env:SystemDrive\Users" | ?{$_.PSChildName -inotin $childrenToOmit} | %{
	$filesToModify += "$($_.PSPath)\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"
}

# iterate through all files and update XML
Write-Host "Begin updating LayoutModification.xml for all user profiles."
foreach ($path in $filesToModify) {
	if (Test-Path -Path $path) {
		try {
			Write-Host "Beginning alteration of file at [$path]."

			# get current file content
			[string]$content = Get-Content -Path $path -Raw -ErrorAction Stop

			# delete the IE taskbar pinned item
			Write-Host "Deleting any taskbar item matching IE."
			$newcontent = $content -ireplace '<taskbar:([^>]*)?Internet Explorer([^>]*)?\/>', ' '

			# delete the IE start menu pinned item
			Write-Host "Deleting any Start Menu item matching IE."
			$newcontent = $newcontent -ireplace '<start:([^>]*)?Internet Explorer([^>]*)?\/>', ' '

			# write content changes
			Write-Host "Writing changes back to [$path]."
			Set-Content -Path $path -Value $newcontent -Force -ErrorAction Stop
		}
		catch {
			Write-Host "Error while updating LayoutModification [$path]:" -ForegroundColor Red
			Write-Host $_.Exception.Message -ForegroundColor Red
			Write-Host "Not a critical failure.  Continuing..."
		}
	}
	else {
		Write-Host "Failed to find the LayoutModification file at [$path]. Skipping file." -ForegroundColor Yellow
	}
}

Write-Host "Finished updating LayoutModification.xml files."
