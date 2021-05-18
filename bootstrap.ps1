param([String]$AirConfigPath="airsdk\32.0.0.116\frameworks\flex-config.xml")

Set-StrictMode -Version Latest

if (-not (Test-Path -Path $AirConfigPath -PathType Leaf)) {
    "Supplied SDK Contig path is invalid. Please supply path to your flex-config.xml."
}

else
{
    $LibraryXPath = "/flex-config/compiler/external-library-path/path-element"
    $AdjustedLibraryPath = "libs/player/32.0/playerglobal.swc"
    
    $NewXml = [XML](Get-Content $AirConfigPath)
    $NewXml | Select-Xml -XPath $LibraryXPath | ForEach-Object {$_.Node.set_Innerxml($AdjustedLibraryPath)}
    $NewXml.Save($AirConfigPath)
    "Successfully bootstrapped the Air SDK."
}

# SIG # Begin signature block
# MIISggYJKoZIhvcNAQcCoIISczCCEm8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDzyShCKMdsPnSU
# Gg7+RFmPkCdervR5QVGm8HmTygqZGKCCDaQwggNpMIICUaADAgECAhBHAdI3ecdg
# vkGGpG/BMAlaMA0GCSqGSIb3DQEBCwUAMDoxFDASBgNVBAMMC0FkYW0gQnJ5YW50
# MSIwIAYJKoZIhvcNAQkBFhNoZWxsb0BhZGFtYnJ5YW50LmNhMB4XDTIwMDQwNDA0
# MTM1NFoXDTIzMDQwNDA0MjM1NVowOjEUMBIGA1UEAwwLQWRhbSBCcnlhbnQxIjAg
# BgkqhkiG9w0BCQEWE2hlbGxvQGFkYW1icnlhbnQuY2EwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQCX1JVw+NmlLCkIa6/u67DkpdlRQ96+oJQJqXefSx83
# mSVOg3F0VJEjVdT1ZPbO4ikruvnyqoA2RGzlAiMxweE0tE7eR+m5G55wo1oQwFzi
# A94fJioKjEkJ7TeKkXVmsqrbnhwI5kdFU1+NkQ/F0RPVbYIHpEsI/eSNneLl2OAx
# SkWkoLuLcThuazxYW/oZyTWi0daZRjRyTp+LVwgBlK6G3QPy6TWAm8O17hSJDNID
# TpW65PuoK53qFo0baf5YVKoANc2e9FgRizMslqmD/jIpBZco7SNdeCGzVQwojrKJ
# 4iXxt77CXR7Th+9Qg4EKTQ5GxYHHaL+W5l7Hrja1Ye+FAgMBAAGjazBpMA4GA1Ud
# DwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAjBgNVHREEHDAaghhmbGFz
# aGZsYXNocmV2b2x1dGlvbi5jb20wHQYDVR0OBBYEFJ+iLpZ+XBc6UaVa7GovUO1Y
# HxIOMA0GCSqGSIb3DQEBCwUAA4IBAQBesYPgcrXkbBIDa8ODSOhnQp/TkLIXpEh7
# LwNvL2WLr09b9Oc1yITlKszfTStwCvZ3CySrFPvX8Q5MrXi+YOQqlEhJds9oL+tH
# w1BOUVS7LpwSuxgyyPAc9JbMI3LqiiTWn4mql/UPrzRWdyGjY0o4H4hoEQoeGmSQ
# iFn0EaAkblpcKgN7e47lZFLkWJungNoXY0i757lxiSZor3ntH3EGeVvtq+Cqyy98
# Q86qq1KUmGkcaz0v1bMV4FkeANN221NNnNhXZKruJP/RHx2KXY4Eia8Lyz3q3L2b
# lmYr7/LMQlq94d0ptywQBeJd8a0Vct6lRl+CCZxqTWSZcdBP3N74MIIE/jCCA+ag
# AwIBAgIQDUJK4L46iP9gQCHOFADw3TANBgkqhkiG9w0BAQsFADByMQswCQYDVQQG
# EwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNl
# cnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgVGltZXN0
# YW1waW5nIENBMB4XDTIxMDEwMTAwMDAwMFoXDTMxMDEwNjAwMDAwMFowSDELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQDExdEaWdp
# Q2VydCBUaW1lc3RhbXAgMjAyMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAMLmYYRnxYr1DQikRcpja1HXOhFCvQp1dU2UtAxQtSYQ/h3Ib5FrDJbnGlxI
# 70Tlv5thzRWRYlq4/2cLnGP9NmqB+in43Stwhd4CGPN4bbx9+cdtCT2+anaH6Yq9
# +IRdHnbJ5MZ2djpT0dHTWjaPxqPhLxs6t2HWc+xObTOKfF1FLUuxUOZBOjdWhtyT
# I433UCXoZObd048vV7WHIOsOjizVI9r0TXhG4wODMSlKXAwxikqMiMX3MFr5FK8V
# X2xDSQn9JiNT9o1j6BqrW7EdMMKbaYK02/xWVLwfoYervnpbCiAvSwnJlaeNsvrW
# Y4tOpXIc7p96AXP4Gdb+DUmEvQECAwEAAaOCAbgwggG0MA4GA1UdDwEB/wQEAwIH
# gDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEEGA1UdIAQ6
# MDgwNgYJYIZIAYb9bAcBMCkwJwYIKwYBBQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNl
# cnQuY29tL0NQUzAfBgNVHSMEGDAWgBT0tuEgHf4prtLkYaWyoiWyyBc1bjAdBgNV
# HQ4EFgQUNkSGjqS6sGa+vCgtHUQ23eNqerwwcQYDVR0fBGowaDAyoDCgLoYsaHR0
# cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC10cy5jcmwwMqAwoC6G
# LGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtdHMuY3JsMIGF
# BggrBgEFBQcBAQR5MHcwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0
# LmNvbTBPBggrBgEFBQcwAoZDaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0U0hBMkFzc3VyZWRJRFRpbWVzdGFtcGluZ0NBLmNydDANBgkqhkiG9w0B
# AQsFAAOCAQEASBzctemaI7znGucgDo5nRv1CclF0CiNHo6uS0iXEcFm+FKDlJ4Gl
# TRQVGQd58NEEw4bZO73+RAJmTe1ppA/2uHDPYuj1UUp4eTZ6J7fz51Kfk6ftQ557
# 57TdQSKJ+4eiRgNO/PT+t2R3Y18jUmmDgvoaU+2QzI2hF3MN9PNlOXBL85zWenva
# DLw9MtAby/Vh/HUIAHa8gQ74wOFcz8QRcucbZEnYIpp1FUL1LTI4gdr0YKK6tFL7
# XOBhJCVPst/JKahzQ1HavWPWH1ub9y4bTxMd90oNcX6Xt/Q/hOvB46NJofrOp79W
# z7pZdmGJX36ntI5nePk2mOHLKNpbh6aKLzCCBTEwggQZoAMCAQICEAqhJdbWMht+
# QeQF2jaXwhUwDQYJKoZIhvcNAQELBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoT
# DERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UE
# AxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTE2MDEwNzEyMDAwMFoX
# DTMxMDEwNzEyMDAwMFowcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0
# IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNl
# cnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAL3QMu5LzY9/3am6gpnFOVQoV7YjSsQOB0UzURB9
# 0Pl9TWh+57ag9I2ziOSXv2MhkJi/E7xX08PhfgjWahQAOPcuHjvuzKb2Mln+X2U/
# 4Jvr40ZHBhpVfgsnfsCi9aDg3iI/Dv9+lfvzo7oiPhisEeTwmQNtO4V8CdPuXcia
# C1TjqAlxa+DPIhAPdc9xck4Krd9AOly3UeGheRTGTSQjMF287DxgaqwvB8z98OpH
# 2YhQXv1mblZhJymJhFHmgudGUP2UKiyn5HU+upgPhH+fMRTWrdXyZMt7HgXQhBly
# F/EXBu89zdZN7wZC/aJTKk+FHcQdPK/P2qwQ9d2srOlW/5MCAwEAAaOCAc4wggHK
# MB0GA1UdDgQWBBT0tuEgHf4prtLkYaWyoiWyyBc1bjAfBgNVHSMEGDAWgBRF66Kv
# 9JLLgjEtUYunpyGd823IDzASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQE
# AwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB5BggrBgEFBQcBAQRtMGswJAYIKwYB
# BQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0
# cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDBQBgNVHSAE
# STBHMDgGCmCGSAGG/WwAAgQwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGln
# aWNlcnQuY29tL0NQUzALBglghkgBhv1sBwEwDQYJKoZIhvcNAQELBQADggEBAHGV
# EulRh1Zpze/d2nyqY3qzeM8GN0CE70uEv8rPAwL9xafDDiBCLK938ysfDCFaKrcF
# NB1qrpn4J6JmvwmqYN92pDqTD/iy0dh8GWLoXoIlHsS6HHssIeLWWywUNUMEaLLb
# dQLgcseY1jxk5R9IEBhfiThhTWJGJIdjjJFSLK8pieV4H9YLFKWA1xJHcLN11ZOF
# k362kmf7U2GJqPVrlsD0WGkNfMgBsbkodbeZY4UijGHKeZR+WfyMD+NvtQEmtmyl
# 7odRIeRYYJu6DC0rbaLEfrvEJStHAgh8Sa4TtuF8QkIoxhhWz0E0tmZdtnR79VYz
# Ii8iNrJLokqV2PWmjlIxggQ0MIIEMAIBATBOMDoxFDASBgNVBAMMC0FkYW0gQnJ5
# YW50MSIwIAYJKoZIhvcNAQkBFhNoZWxsb0BhZGFtYnJ5YW50LmNhAhBHAdI3ecdg
# vkGGpG/BMAlaMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKA
# AKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIG/8vgEtyf+bQkcFV1R2+ghn
# QZc8ChcwjPl8Z5LprVWPMA0GCSqGSIb3DQEBAQUABIIBAFY1zCMVTpQ9j/YKf6Xw
# kC5hbFLo9+QashfYt35GFLTCb/ejrgvd3z6wwy1cJFiqQeF45eIBXFfErycJsi5Y
# 53UkFjtkLI1KIHdEJ1Nw+RTEh0Zq99N27kCpf+l9Pdl0dMF4ytBG79GawsaQmmC0
# 8TCg0B7e+0E9ZmpbjQ7mrGPCCy38GUEF/CNWXlYzceox5z7tJ2nRLeRlmsbf0X+B
# O+ZP/Ru5GobN2sjZ1XvU4ODf7XJs1UbYGW5jWQkbNjKlsubmiC53V2CkMPdVCrD1
# AvXjOWSmlFk7yKBTZa892woGSfHIztbfaCSvJcz7GP7enWQrmkFHYTC1A6YumFtA
# uMehggIwMIICLAYJKoZIhvcNAQkGMYICHTCCAhkCAQEwgYYwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFt
# cGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TANBglghkgBZQMEAgEFAKBpMBgGCSqG
# SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIxMDQyNDE4MTg0
# OVowLwYJKoZIhvcNAQkEMSIEIKhIo08/47NvYDYTCgt//Z2z52oCYm2j3nGAYz4D
# ObiFMA0GCSqGSIb3DQEBAQUABIIBAGwYmgNjGy8SGdj2QzwA1rE4LLz8kNKNmAqh
# Rvyp67eeDU+uNy6XY53fv03OVJYi8MV+ip2m8hElP+T0c59VeNSZI+qDkXbHLeRU
# 40s992AnA8iQafMl5XZOiNCyXpBmQLVtZQq/A0l28Ja1BPaquSG35GtKOIkgXDKk
# pel0v9aJ1O4JI4qyylBI6d6QzuQo74cSJvFjUtC9uUW0VvuT5LSaX2Hgtt8ONU+4
# 1upADaS5Bmcd2X76BQZcb46OA2aa6xxHTfZHWKXuGIA8dv65PVhalhKzUi3Tk+Xi
# IoPMI5ckaFHmdcW7NY1BKS3894vyeeCsGIxGDQFL+3Pqqvo7jhE=
# SIG # End signature block