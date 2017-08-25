// example page
// http://forum.cheatengine.org/viewtopic.php?p=5730624#5730624
function textNodesUnder(el){
  var n, a=[], walk=document.createTreeWalker(el,NodeFilter.SHOW_TEXT,null,false);
  while(n=walk.nextNode()) a.push(n);
  return a;
}
var texts = textNodesUnder(document.querySelector('table.forumline')).filter(function(e,i,a){return e.length > 200; })
for (var i in texts) {
  var text = texts[i]
  var nodes = []
  for (var remaining = text.splitText(200);
    remaining.length > 200;
    remaining = remaining.splitText(200)) {
      nodes.push(remaining)
   }
  for (var j in nodes) nodes[j].parentNode.insertBefore(document.createElement('br'), nodes[j]);
  var last = nodes[nodes.length-1]
  if (!last) { continue }
  last.parentNode.insertBefore(document.createElement('br'), last.nextSibling)
}


// minified
javascript:function textNodesUnder(e){for(var t,n=[],r=document.createTreeWalker(e,NodeFilter.SHOW_TEXT,null,!1);t=r.nextNode();)n.push(t);return n}var texts=textNodesUnder(document.querySelector("table.forumline")).filter(function(e,t,n){return e.length>200});for(var i in texts){for(var text=texts[i],nodes=[],remaining=text.splitText(200);remaining.length>200;remaining=remaining.splitText(200))nodes.push(remaining);for(var j in nodes)nodes[j].parentNode.insertBefore(document.createElement("br"),nodes[j]);var last=nodes[nodes.length-1];last&&last.parentNode.insertBefore(document.createElement("br"),last.nextSibling)}


// CSS version
var s = document.createElement('style')
s.innerHTML = '.long { table-layout: fixed;max-width: 100vw;word-wrap: break-word; }'
document.head.append(s)
for (var i=0,l=document.querySelectorAll('table.forumline table'); i < l.length; i++) l[i].classList.add('long')
// button fix
for (var i=0,l=document.querySelectorAll('td[valign="top"][nowrap="nowrap"]'); i < l.length; i++) if(l[i].previousElementSibling) l[i].previousElementSibling.width='90%'


// minified (without function the page simply changed to a blank page with '90%' on it)
javascript:!function(){var s=document.createElement("style");s.innerHTML=".long { table-layout: fixed;max-width: 100vw;word-wrap: break-word; }",document.body.append(s);for(var i=0,l=document.querySelectorAll("table.forumline table");i<l.length;i++)l[i].classList.add("long");for(var i=0,l=document.querySelectorAll('td[valign="top"][nowrap="nowrap"]');i<l.length;i++)l[i].previousElementSibling&&(l[i].previousElementSibling.width="90%");}()
