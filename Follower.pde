PImage img;
PGraphics pg;

void setup(){
  size(800,600);
	pg = createGraphics(width, height);
  pg.beginDraw();
  pg.clear();
  pg.endDraw();
  img = loadImage("car.png"); 
}

void draw(){
	background(255);
	if (mousePressed) {
    pg.beginDraw();
    pg.stroke(0);
    pg.strokeWeight(8);
    pg.line(mouseX, mouseY, pmouseX, pmouseY);
    pg.endDraw();
  }
  image(pg, 0, 0);
  car();
	sensor();
}

float x=3*width,y=3*height;
float dx,dy;
float angle;
boolean left, right;

int R=30;
int r=2;

//ML parameters
float w1[] = new float[]{-2.18834926, -3.41803251, -3.86206085, -2.34904363,
													2.3384179 , 2.16570049,  3.40533975,  3.90349181};
float w2[] = new float[]{2.02035103, -2.03284004};
float b1 = 0.03596949;
float b2[] = new float[]{-0.18288721, -0.04979274};

void car(){
	translate(x,y);
  rotate(radians(360-angle));
  image(img,-img.width/16,-img.height/16,img.width/8,img.height/8);
	
	//pushMatrix();
  
  rotate(-radians(360-angle));
  translate(-x,-y);
}

void sensor(){
  x+=dx;
  y+=dy;
	
	if (x<0) x = width; 
	if (x>width) x = 0;
	if (y<0) y = height; 
	if (y>height) y = 0;
  
	// Check detectors.
	float vx[]= new float[8];
	float vy[]= new float[8];
	color c[]=new color[8];
	for (int i=0; i<8; i++) {
		vx[i] = x + R*sin(i*PI/16+radians(angle)-3*PI/16-PI/32); 
		vy[i] = y + R*cos(i*PI/16+radians(angle)-3*PI/16-PI/32);
		ellipse(vx[i], vy[i], 2*r, 2*r);
		c[i] = pg.get((int)vx[i], (int)vy[i]);
		
		//if (i==5 && c[5]!=0 ) left = true;
		//if (i==2 && c[2]!=0 ) right = true;
		
		if(c[i]!=0)
			c[i]=1;
		print(c[i]);
		print(' ');
	}
	//predict
	float val1= 0;
	float turn[]= new float[2];
	double a1,a2[]= new double[2];
	
	for(int i=0;i<8;i++){
		val1 += c[i]*w1[i];
	}
	val1+=b1;
	a1= Math.tanh(val1);
	
	for(int i=0;i<2;i++){
		turn[i]= (float)a1 * w2[i]+b2[i];
		a2[i]= sigmoid(turn[i]);
	}
	
	print(a2[0]);
	print(' ');
	print(a2[1]);
	
	if(a2[0]>0.8){
		left=true;
	}
	if(a2[1]>0.8){
		right=true;
	}
	
	println();
	// Turning,
	if (left) {
		angle+=3;
		dx =  sin(radians(angle));
		dy =  cos(radians(angle));
		left = false;
	}   
	if (right) {
		angle-=3;
		dx =  sin(radians(angle));
		dy =  cos(radians(angle));
		right = false;
	}

	//translate(x,y);
  //rotate(radians(360-angle));
  //image(img,-img.width/16,-img.height/16,img.width/8,img.height/8);
  
  //popMatrix();
  
  //dx=sin(radians(angle));
  //dy=cos(radians(angle));
}

double sigmoid(float x){
	return(1/(1+ Math.pow(Math.E,(-1*x))));
}

void keyPressed(){
  if(key=='a')
    angle+=10;
  if(key=='d')
    angle-=10;
}
