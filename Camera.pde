void look(){
  float minX = min(box2d.getBodyPixelCoord(player1.body).x, box2d.getBodyPixelCoord(player2.body).x);
  float minY = min(box2d.getBodyPixelCoord(player1.body).y, box2d.getBodyPixelCoord(player2.body).y);
  float maxX = max(box2d.getBodyPixelCoord(player1.body).x, box2d.getBodyPixelCoord(player2.body).x);
  float maxY = max(box2d.getBodyPixelCoord(player1.body).y, box2d.getBodyPixelCoord(player2.body).y);
  
  
  translate(-(minX + maxX)/2 + width/2, height/2 - (minY+maxY)/2);
}
