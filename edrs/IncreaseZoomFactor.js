function increaseMaxZoomFactor() {
    
    var element = document.createElement_x('meta');
    
    element.name = "viewport";
    
    element.content = "maximum-scale=10";
    
    var head = document.getElementsByTagName_r('head')[0];
    
    head.appendChild(element);
    alert("1111")
}
