class CQHttp
{
    [string]$ApiRoot

    [System.Net.HttpListener]$_listener;

    Run ()
    {
        $this.Run("127.0.0.1:8080")
    }

    Run ([string]$Address)
    {
        $url = "http://$Address/"

        $this._listener = [System.Net.HttpListener]::new()
        $this._listener.Prefixes.Add($url)
        $this._listener.Start()

        if ($this._listener.IsListening)
        {
            Write-Log "CQHTTP bot is running on $url..." -Level Info
        }
        else
        {
            Write-Log "Failed to start HTTP listener" -Level Error
        }

        $this._listenRequest()
    }

    _listenRequest()
    {
        while ($this._listener.IsListening)
        {
            $context = $this._listener.GetContext()  # Accept request
            $method = $context.Request.HttpMethod
            $path = $context.Request.RawUrl
            $body = ""

            if ($method -ne "POST")
            {
                $statusCode = 405
            }
            elseif ($path -ne "/")
            {
                $statusCode = 404
            }
            else
            {
                $statusCode = 204
                $body = [System.IO.StreamReader]::new($context.Request.InputStream).ReadToEnd()
            }

            Write-AccessLog -Method $method -Path $path -StatusCode $statusCode
            $context.Response.StatusCode = $statusCode
            $context.Response.OutputStream.Close()

            if (-not $body)
            {
                continue
            }

            Write-Log -Message "Received body: $body" -Level Debug

            try
            {
                $payload = $body | ConvertFrom-Json
            }
            catch
            {
                continue
            }

            $postType = $payload.post_type
            if (-not $postType)
            {
                continue
            }

            $detailType = $payload."${postType}_type"
            $event = "${postType}.${detailType}"

            if ($payload.sub_type)
            {
                $event += ".$($payload.sub_type)"
            }

            Write-Log -Message "Emitting event: $event" -Level Info
            $this._emitEvent($event, $payload)
        }
    }

    _emitEvent($Event, $Payload)
    {
        $body = @{
            user_id = $Payload.user_id
            message = $Payload.message
        } | ConvertTo-Json
        $body = [System.Text.Encoding]::UTF8.GetBytes($body);

        Invoke-WebRequest `
            -Uri "$($this.ApiRoot)/send_private_msg" `
            -Method Post `
            -ContentType "application/json; charset=utf-8" `
            -Body $body
    }
}
