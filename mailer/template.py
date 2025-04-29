def build_template(data, reflexao):
    return f"""
<!DOCTYPE html>
<html lang="pt-br">
  <head>
    <meta charset="UTF-8" />
    <title>Liturgia Diária</title>
    <style>
        
    </style>
  </head>
  <body style="margin: 0; padding: 20px; background-color: #f4f4f4; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #333;">
    <table align="center" cellpadding="0" cellspacing="0" width="100%" style="max-width: 800px; background-color: #ffffff; border-radius: 8px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);">
      <tr>
        <td align="center" bgcolor="#78350f" style="padding: 40px 20px; color: #ffffff;">
          <h1 style="margin: 0; font-size: 24px;">Liturgia Diária</h1>
          <p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">Reflexões inspiradoras para enriquecer sua jornada espiritual</p>
        </td>
      </tr>
      <tr>
        <td style="padding: 10px 20px;">
          <p style="font-size: 16px; color: #888; margin-bottom: 10px;">
            Reflexão de hoje: <strong>{data}</strong>
          </p>
          <p style="font-size: 17px; margin-bottom: 20px; color: #555;">
            Você pode acompanhar a <strong>Liturgia Diária</strong> diretamente pelo site da 
            <a href="https://liturgia.cancaonova.com/pb/" target="_blank" style="color: blue; text-decoration: underline;">Canção Nova</a>.
          </p>
          <hr style="border: none; border-top: 2px solid #eee; margin-bottom: 20px;" />
          <h3 style="font-size: 20px; color: #4b2e16; margin-bottom: 15px;">Reflexão</h3>
          <div style="font-size: 16px; line-height: 1.8; text-align: justify; color: #333;">
            {reflexao}
          </div>
        </td>
      </tr>
    </table>
  </body>
</html>
    """