# 대상 폴더 위치
$files = Get-ChildItem ".\"

# 숫자 순서대로 이름을 변경
$i = 1
foreach ($file in $files) {
  Rename-Item $file.FullName -NewName ("illust_" + $i + $file.Extension)
  $i++
}
