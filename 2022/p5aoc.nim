# palettes from https://openprocessing.org/sketch/1751402
let
  colBackground* = "#324759"
  colTransparent* = "#ffffff00"
  colDark* = "#0f0f23"
  colGold* = "#ffff66"
  colGreen* = "#009900"
  colBrightGreen* = "#99ff99"
  colRed* = "#B5453A"
  colRust* = "#DEA584"
  palAoc* = [colGreen, colBrightGreen, colGold, colRust, colRed]
  palBenedictus* = @["#F27EA9", "#366CD9", "#5EADF2", "#636E73", "#F2E6D8"]
  palCross* = @["#D962AF", "#58A6A6", "#8AA66F", "#F29F05", "#F26D6D"]
  palDemuth* = @["#222940", "#D98E04", "#F2A950", "#BF3E21", "#F2F2F2"]
  palHiroshige* = @["#1B618C", "#55CCD9", "#F2BC57", "#F2DAAC", "#F24949"]
  palHokusai* = @["#074A59", "#F2C166", "#F28241", "#F26B5E", "#F2F2F2"]
  palHokusaiBlue* = @["#023059", "#459DBF", "#87BF60", "#D9D16A", "#F2F2F2"]
  palJava* = @["#632973", "#02734A", "#F25C05", "#F29188", "#F2E0DF"]
  palKandinsky* = @["#8D95A6", "#0A7360", "#F28705", "#D98825", "#F2F2F2"]
  palMonet* = @["#4146A6", "#063573", "#5EC8F2", "#8C4E03", "#D98A29"]
  palNizami* = @["#034AA6", "#72B6F2", "#73BFB1", "#F2A30F", "#F26F63"]
  palRenoir* = @["#303E8C", "#F2AE2E", "#F28705", "#D91414", "#F2F2F2"]
  palVanGogh* = @["#424D8C", "#84A9BF", "#C1D9CE", "#F2B705", "#F25C05"]
  palMono* = @["#D9D7D8", "#3B5159", "#5D848C", "#7CA2A6", "#262321"]
  palRiverside* = @["#906FA6", "#025951", "#252625", "#D99191", "#F2F2F2"]
  palettes* = [palBenedictus, palCross, palDemuth, palHiroshige, palHokusai, palHokusaiBlue, palJava, palKandinsky, palMonet, palNizami, palRenoir, palVanGogh, palMono, palRenoir]
  palNames* = ["Benedictus", "Cross", "Demuth", "Hiroshige", "Hokusai", "HokusaiBlue", "Java", "Kandinisky", "Monet", "Nizami", "Renoir", "VanGogh", "Mono", "Renoir"]

when isMainModule:
  import nimib, p5
  nbInit
  nbUseP5
  nb.darkMode
  nbJsFromCode(palettes, palNames, palAoc, colDark):
    setup:
      drawCanvas(200, 20*(len(palettes) + 1))
      background(colDark)