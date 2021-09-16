Import-Module ActiveDirectory
$PSEmailServer = "my-server.domain" #Your mailserver

#Create warning dates for future password expiration
$daystoexpire = 7
$today = Get-Date

#Static E-Mail variables
$MailSender = "Sender name <sender@email>”

#Find accounts that are enabled and have expiring passwords
$users = Get-ADUser -filter {(Enabled -eq $True) -and (PasswordNeverExpires -eq $False) -and (PasswordLastSet -gt 0)} -Properties “Name”, “EmailAddress”, “msDS-UserPasswordExpiryTimeComputed” | Select-Object -Property “Name”, “EmailAddress”, @{Name = “PasswordExpiry”; Expression = {[datetime]::FromFileTime($_.”msDS-UserPasswordExpiryTimeComputed”).tolongdatestring() }}

#Check password expiration date and send email on match
foreach ($user in $users) {
    $ts = New-TimeSpan -Start $today -End $user.PasswordExpiry
        if($ts.Days -le $daystoexpire -and $ts.Days -ge "0")
            {            


#Example Email
$Subject = "Your password will expire on $($user.PasswordExpiry)"
$body ="
     <font face = ""Arial"">
     <font size = 2> 
    <p>Hello $($user.name),<br>
    
    your Windows password will expire on $($user.PasswordExpiry).<br>
    Please change it.
    </p>
    <I>Dies ist eine automatische Benachrichtigung</I>
    </font>"
    
#Send Email to User
Send-MailMessage -To $user.EmailAddress -From $MailSender -Subject $Subject -Body $body -BodyAsHtml

#Reset variable
$ts = $null
$subject = $null 
$body = $null
}
}
Stop-Transcript  