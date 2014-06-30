library scroll_roll;
// Copyright (c) 2014, .  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'package:polymer/polymer.dart';


@CustomTag('scroll-roll')
class ScrollRoll extends PolymerElement {

  @published List listOfItems;
  @PublishedProperty(reflect: true) String resultItem;
  @published bool debugOn=false;
  @published String cssheight = "";
  @published String csswidth = "";
  @PublishedProperty(reflect: true) int fontsize;
  @PublishedProperty(reflect: true) int containerposition;
  @PublishedProperty(reflect: true) int cssintheight;
  @PublishedProperty(reflect: true) int cssintwidth;

Element target;
Element container;
var figureHeight;
num radius;
double anglePos = 0.0;
num theListNumber;
num spinNum = 0;
num childCount = 0;
Timer timer;
int touchStartX;
int touchStartY;
bool ownMouse;
StreamSubscription theKeyDownListener;
StreamSubscription theKeyUpListener;

ScrollRoll.created() : super.created() {

  if (cssheight == ""){
   cssintheight = 200;
  } else {
    //cssheight = 200;
    cssintheight = int.parse(cssheight);
  }
  if (csswidth == ""){
    cssintwidth = 100;
  } else {
    //csswidth = 100;
    cssintwidth = int.parse(csswidth);
  }

}


  void attached() {
    super.attached();
    ownMouse = false;
    childCount = listOfItems.length;
    if(debugOn ==true ){
      print("list of items: $listOfItems, $childCount");
    }
    target = $['target'];
    //target = querySelector('#target');
    container = $['container'];

    initialize3D();


    if (resultItem != ""){
      //check if the resultItem is in the list
      if (listOfItems.contains(resultItem)){
        num index = listOfItems.indexOf(resultItem);
        spinFigure(target, index);
      }
    }
    // Handle touch events.

    container.onTouchStart.listen((TouchEvent event) {
      event.preventDefault();

      if (event.touches.length > 0) {
        touchStartX = event.touches[0].page.x;
        touchStartY = event.touches[0].page.y;
      }
    });

      container.onTouchMove.listen((TouchEvent event) {
      event.preventDefault();

      if (touchStartX != null && event.touches.length > 0) {
        int newTouchX = event.touches[0].page.x;

        if (newTouchX > touchStartX) {
          spinFigure(target, (newTouchX - touchStartX) ~/ 20 + 1);
          touchStartX = null;
        } else if (newTouchX < touchStartX) {
          spinFigure(target, (newTouchX - touchStartX) ~/ 20 - 1);
          touchStartX = null;
        }
      }

      if (touchStartY != null && event.touches.length > 0) {
        int newTouchY = event.touches[0].page.y;

        if (newTouchY > touchStartY) {
          spinFigure(target, (newTouchY- touchStartY) ~/ 20 - 1);
          touchStartY = null;
        } else if (newTouchY < touchStartY) {
          spinFigure(target, (newTouchY - touchStartY) ~/ 20 + 1);
          touchStartY = null;
        }
      }
    });

    container.onTouchEnd.listen((TouchEvent event) {
    event.preventDefault();

    touchStartX = null;
    touchStartY = null;
  });



  }


void initialize3D() {
  if (debugOn == true){
    print("target is : $target");
  }
  target.classes.add("transformable");

    scheduleMicrotask(() {
      //num height = querySelector("#target").client.height;
      //figureHeight = (height/2) ~/ tan(PI/childCount);
      //target.style.transform = "translateZ(-${figureHeight}px)";
      //radius = (figureHeight * 1.2).round();
      //querySelector('#container2').style.height = "${radius}px";

      // calculate the height of the item to be rotated, in its space
      // then calculate the amount of items.
      // the circel should contain at least these amount of items.
      // So 10 items of 100 px gives a cirkel of 1000px length, meaning a
      // radius of 1000px/2PI. We increase that a little to distance the figures from themselves

//      num height = target.querySelector('#target figure').client.height;
//      num height = target.querySelector('.figure').client.height;
      // the height of the container is 30 % of the container size.
      num containerHeight = cssintheight;
//      num containerHeight = (this.shadowRoot.querySelector('#container').client.height);
//      num height = this.shadowRoot.querySelector('figure').client.height;
      //num height = target.client.height;
      // the figureheight has to fit into the container with the complete circle.
      // the radius of the circle has to be the half of the height
      // otherwise the circle will not fit into the container
      // then we calculate the total lenght this circle will have (which is 2*PI*Radius)
      // then we calculate the height that one figure can have (which is the lenght of the
      // circle divided by the amount of figures
      if (childCount > 1){
        num lengthOfCircle = 2*PI*(containerHeight/2);
        figureHeight = ((lengthOfCircle/childCount)*0.80).round();
        fontsize = (figureHeight *0.8).round();
        // the height of the figure should be around 50 % of the height to be centered
        // that means the position should be calculated according to the size of the
        // figureHeigth
        num remainsOfHeight = (containerHeight/2)-(figureHeight/2);
        containerposition = remainsOfHeight.round();
        //containerposition = (figureHeight *0.7).round();
        // we translate the target around which everything should circle in the middle of the circle
        // move the first item the length of the radius backwards and half the height downwards
        radius = ((lengthOfCircle/(2*PI))*0.8).round();
      } else {
//        num lengthOfCircle = 2*PI*(containerHeight/2);
//        figureHeight = ((lengthOfCircle/childCount)*0.9).round();
        figureHeight = ((containerHeight/4)).round();
        fontsize = (figureHeight *0.8).round();
//        containerposition = (figureHeight *0.7).round();
//        num remainsOfHeight = (containerHeight/2)-figureHeight;
//        containerposition = ((containerHeight/2)-remainsOfHeight).round();
        num remainsOfHeight = (containerHeight/2)-(figureHeight/2);
        containerposition = remainsOfHeight.round();
        radius = 0;
      }
      $['container2'].style.height = "${figureHeight}px";
//      querySelector('#container2').style.height = "${height}px";
      target.style.transform = "translateZ(-${radius}px)";
//      target.style.transform = "translateZ(-${radius}px) translateY(-${figureHeight}px)";
    if (debugOn == true){
       print("height:$containerHeight figureheight: $figureHeight, radius: $radius");
    }
    for (int i = 0; i <= childCount; i++) {
      var panel = target.children[i];
      panel.classes.add("transformable");
//      if (i > 0){
      panel.style.transform =
          "rotateX(${i * (360 / childCount)}deg) translateZ(${radius}px)";
//      } else {
//        panel.style.transform =
//            "rotateX(${i * (360 / childCount)}deg) translateZ(${radius}px)";
//      }
    }

    spinFigure(target, 0);
  });
}


void focusForKeyStrokes(){
  if (debugOn == true){
    print("keystrokes  focus ");
  }
  ownMouse = true;
  listenToKeyStrokes();
}

void removeFocusForKeyStrokes(){
  if (debugOn == true){
    print("keystrokes  remove focus ");
  }
  ownMouse = false;
  listenToKeyStrokes();
}

void listenToKeyStrokes(){

  if (ownMouse == true){
   // Handle key events.
   theKeyDownListener = document.onKeyDown.listen((KeyboardEvent event) {
     switch (event.keyCode) {
       case KeyCode.DOWN:
         startSpin(target, -1);
         break;
       case KeyCode.UP:
         startSpin(target, 1);
         break;
       case KeyCode.LEFT:
         spinFigure(target, -2);
         break;
       case KeyCode.RIGHT:
         spinFigure(target, 2);
         break;
     }
   });

   theKeyUpListener = document.onKeyUp.listen((event) => stopSpin());

   } else {
     if (theKeyDownListener != null){
      theKeyDownListener.cancel();
     }
     if (theKeyUpListener !=null){
      theKeyUpListener.cancel();
     }
   }


}

void spinFigure(Element figure, int direction) {
  // calculate the current position in the list of figures
  spinNum = spinNum-direction;
  theListNumber = (spinNum-1) % childCount;
  //Node theFigureNode = theChildrenList[theListNumber];
  //String theText = theFigureNode.text;
  var theItem = listOfItems[theListNumber];
  if (debugOn == true){
    print("theListNumber: $theListNumber, spinNum: $spinNum, item: $theItem");
  }
  // rotate the whole stuff depending on the amount of figures
  anglePos += (360.0 / childCount) * direction;
    figure.style.transform =
       "rotateX(${anglePos}deg)";
      // "rotateX(${anglePos}deg) translateZ(-${figureHeight}px)";
}

/**
 * Start a spin in the given direction.
 */
void startSpin(Element figure, int direction) {
  // If we're not already spinning -
  if (timer == null) {
    spinFigure(figure, direction);

    timer = new Timer.periodic(const Duration(milliseconds: 150),
        (Timer t) => spinFigure(figure, direction));
  }
}

/**
 * Stop any spin that may be in progress.
 * Set the resultItem
 */
void stopSpin() {
  if (timer != null) {
    timer.cancel();
    timer = null;
    resultItem=listOfItems[theListNumber];
  }
}

}
