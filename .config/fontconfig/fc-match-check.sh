# From https://jichu4n.com/posts/how-to-set-default-fonts-and-font-aliases-on-linux/

for family in serif sans-serif monospace Arial Helvetica Verdana "Times New Roman" "Courier New"; do
  echo -n "$family: "
  fc-match "$family"
done