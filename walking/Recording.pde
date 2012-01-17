class Recording {
  CSVMap csvMap;
  ArrayList<Joint> joints;
  int totalFrames;
  ArrayList<Limb> limbs;

  int currentFrame = 0;

  Recording(CSVMap csvMap) {
    joints = new ArrayList();
    limbs = new ArrayList();
    parse(csvMap);
    configureLimbs();
  }

  void configureLimbs() {
    limbs.add(new Limb(this, 2, 0));
    limbs.add(new Limb(this, 0, 1));
    limbs.add(new Limb(this, 1, 7));
    limbs.add(new Limb(this, 1, 11));
    limbs.add(new Limb(this, 5, 11));
    limbs.add(new Limb(this, 5, 4));
    limbs.add(new Limb(this, 4, 3));
    limbs.add(new Limb(this, 7, 5));
    limbs.add(new Limb(this, 7, 6));
    limbs.add(new Limb(this, 6, 8));
    limbs.add(new Limb(this, 11, 10));
    limbs.add(new Limb(this, 10, 9));
  }

  ArrayList<GaitPhase> detectPhases() {
    Joint leftJoint = joints.get(3);
    Joint rightJoint = joints.get(9);
    
    ArrayList<GaitPhase> results = new ArrayList();
    
    for (int i = 1; i < totalFrames-1; i++) {
      // look for local minima in each limb
      boolean leftJointMin = false;
      boolean rightJointMin = false;

      if (leftJoint.positionAtFrame(i).z < leftJoint.positionAtFrame(i-1).z 
        && leftJoint.positionAtFrame(i).z < leftJoint.positionAtFrame(i+1).z) {
        leftJointMin = true;
      }

      if (rightJoint.positionAtFrame(i).z < rightJoint.positionAtFrame(i-1).z 
        && rightJoint.positionAtFrame(i).z < rightJoint.positionAtFrame(i+1).z) {
        rightJointMin = true;
      }


      int phase = -1;
      if (leftJointMin && rightJointMin) {
        phase = GaitPhase.DOUBLE_SUPPORT;
      } 
      else {
        if (leftJointMin) {
          phase = GaitPhase.SINGLE_SUPPORT_LEFT;
        }
        if (rightJointMin) {
          phase = GaitPhase.SINGLE_SUPPORT_RIGHT;
        }
      }
      
      if(phase != -1){
        results.add(new GaitPhase(i, phase));
      }
      
      // if the
    }
    
    return results;
  }
  

  void draw() {
    noStroke();
    fill(254);
    beginShape(QUADS);
    vertex(-1.25, -0.5, 0);
    vertex(-1.25, 0.5, 0);
    vertex(3.25, 0.5, 0);
    vertex(3.25, -0.5, 0);
    endShape();
    
    strokeWeight(3);

  stroke(0, 255, 0);
  recording.joints.get(3).drawPath();
  
  stroke(255, 0, 0);
  recording.joints.get(9).drawPath();

    PVector lpos = recording.joints.get(3).positionAtFrame(recording.currentFrame);
    PVector rpos = recording.joints.get(9).positionAtFrame(recording.currentFrame);


  noStroke();
    pushMatrix();
    translate(lpos.x, lpos.y, lpos.z);
    fill(0, 255, 0);

    ellipse(0, 0, 0.08, 0.08);
    popMatrix();

    pushMatrix();
    translate(rpos.x, rpos.y, rpos.z);
    fill(255, 0, 0);
    ellipse(0, 0, 0.08, 0.08);
    popMatrix();

    stroke(0);
    strokeWeight(2);
    for (int i = 0; i < limbs.size(); i ++ ) {
      limbs.get(i).drawAtFrame(currentFrame);
    }
  }

  void nextFrame() {
    currentFrame++;
    if (currentFrame >= totalFrames) {
      currentFrame = 0;
    }
  }

  void parse(CSVMap csvMap) {
    // create one joint for each column set
    // (taking into account dimensionality)
    // then populate joint frames from row triplets/pairs

    // get column headers and create joints
    String[] columnHeaders = csvMap.getColumnHeaders();
    for (int i = csvMap.startColumn; i < columnHeaders.length; i += csvMap.dimensions) {
      joints.add(new Joint(columnHeaders[i]));
    }

    // load data into joints

    for (int i = csvMap.dataStartRow; i < csvMap.rows.length; i++ ) {
      String[] dataColumns = csvMap.getRow(i);
      totalFrames++;

      int currentJointIndex = 0;


      for (int j = csvMap.dataStartColumn; j < dataColumns.length; j += csvMap.dimensions) {   

        float x = float(dataColumns[j]);
        float y = float(dataColumns[j+1]);
        float z = 0; // if we're in 2D, default z to 0

          if (csvMap.dimensions == 3) {
          z = float(dataColumns[j+2]);
        } 

        Joint currentJoint = joints.get(currentJointIndex);
        currentJoint.addFrame(new Frame(x, y, z));
        currentJointIndex++;
      }
    }
  }
}

