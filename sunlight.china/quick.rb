#encoding:UTF-8

s = "钱翊樑所钱翊樑、四维乐马所厉明、君悦所刘正东、恒信所鲍培伦、君合上海所马建军、申汇所李家麟、三石所沈伟明、保华所孙为新、融孚所吕琰、蓝白所陆胤、天一所张善美、江三角所陆敬波、廖得所廖佩娟、中夏旭波所朱素宝、大成上海所徐郭飞"

# group str
ts = s.split "、"
es = [] # do not use hash avoid missing same agent people 
ts.each do |t|
  names = t.split("所")
  es << names
end
# write code 
es.each do |e|
  puts "Pro.new('#{e[0]}所','律师','#{e[1]}'),"
end
