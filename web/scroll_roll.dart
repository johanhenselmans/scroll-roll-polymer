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
  @published String resultItem;
  @published bool debugOn=false;

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


ScrollRoll.created() : super.created() {

}


  void attached() {
    super.attached();
    ownMouse = false;
    childCount = listOfItems.length;
    print("list of items: $listOfItems, $childCount");
    target = $['target'];
    container = $['container'];
    //target = $[querySelector('target')];
    //target = querySelector('#target');

    initialize3D();

    // Handle touch events.

//    target.onTouchStart.listen((TouchEvent event) {
      container.onTouchStart.listen((TouchEvent event) {
      event.preventDefault();

      if (event.touches.length > 0) {
        touchStartX = event.touches[0].page.x;
        touchStartY = event.touches[0].page.y;
      }
    });

//    target.onTouchMove.listen((TouchEvent event) {
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

  print("target is : $target");
  target.classes.add("transformable");

//  num childCount = target.children.length;

    scheduleMicrotask(() {
      //num height = querySelector("#target").client.height;
      //figureHeight = (height/2) ~/ tan(PI/childCount);
      //target.style.transform = "translateZ(-${figureHeight}px)";
      //radius = (figureHeight * 1.2).round();
      //querySelector('#container2').style.height = "${radius}px";

      // calculate the height of the item to be rotated, in it's space
      // then calculate the amount of items.
      // the circel should contain at least these amount of items.
      // So 10 items of 100 px gives a cirkel of 1000px lengt, meaning a
      // radius of 1000px/2PI. We increase that a little to distance the figures from themselves

//      num height = target.querySelector('#target figure').client.height;
//      num height = target.querySelector('.figure').client.height;
      num height = this.shadowRoot.querySelector('figure').client.height;
      //num height = target.client.height;
      figureHeight = ((height/2) ~/ tan(PI/childCount)).round();
      if (childCount > 1){
        num lengthOfCircle = height * childCount;
        // we translate the target around which everything should circle in the middle of the circle
        // move the first item the length of the radius backwards and half the height downwards
        radius = ((lengthOfCircle/(2*PI))*1.0).round();
      } else {
        radius = 0;
      }
      num halfheight = height/2;
      $['container2'].style.height = "${height}px";
//      querySelector('#container2').style.height = "${height}px";
      target.style.transform = "translateZ(-${radius}px)";
//      target.style.transform = "translateZ(-${radius}px) translateY(-${figureHeight}px)";

    print("height:$height figureheight: $figureHeight, radius: $radius");

    for (int i = 0; i < childCount; i++) {
      var panel = target.children[i];
      panel.classes.add("transformable");
      panel.style.transform =
          "rotateX(${i * (360 / childCount)}deg) translateZ(${radius}px)";
    }

    spinFigure(target, 0);
  });
}


void focusForKeyStrokes(){
  print("keystrokes  focus ");
  ownMouse = true;
  listenToKeyStrokes();
}

void removeFocusForKeyStrokes(){
  print("keystrokes  remove focus ");
  ownMouse = false;
  listenToKeyStrokes();
}

void listenToKeyStrokes(){

  if (ownMouse == true){
   // Handle key events.
   document.onKeyDown.listen((KeyboardEvent event) {
//  container.onKeyDown.listen((KeyboardEvent event) {
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

   document.onKeyUp.listen((event) => stopSpin());
//  container.onKeyUp.listen((event) => stopSpin());
//  document.onFocus.listen((event) => focusForKeyStrokes());
//  document.onFocus.listen((event) => focusForKeyStrokes());
//  document.onMouseEnter.listen((event) => focusForKeyStrokes());
//  document.onMouseOver.listen((event) => focusForKeyStrokes());
//  document.onMouseDown.listen((event) => focusForKeyStrokes());
//  document.onMouseUp.listen((event) => focusForKeyStrokes());

   } else {
     document.onKeyDown.close();
     document.onKeyDown.listen((KeyboardEvent event) => doNothing());
     document.onKeyUp.listen((KeyboardEvent event) => doNothing());
   }


}

void doNothing(){
  print("we do nothing..");
}

void spinFigure(Element figure, int direction) {
  // calculate the current position in the list of figures
  spinNum = spinNum-direction;
  theListNumber = (spinNum-1) % childCount;
  //Node theFigureNode = theChildrenList[theListNumber];
  //String theText = theFigureNode.text;
  var theItem = listOfItems[theListNumber];
  // rotate the whole stuff depending on the amount of figures
  if (debugOn){
   print("theListNumber: $theListNumber, spinNum: $spinNum, item: $theItem");
  }
  anglePos += (360.0 / childCount) * direction;
  //for (int i = 0; i < childCount; i++) {
    //var panel = target.children[i];
    // panel.classes.add("transformable");
    //panel.style.transform =
    //  "translateZ(-${radius}px) rotateX(${anglePos*i}deg)";
  //}
    figure.style.transform =
       "rotateX(${anglePos}deg)";
      // "rotateX(${anglePos}deg) translateZ(-${figureHeight}px)";
}

/**
 * Start an indefinite spin in the given direction.
 */
void startSpin(Element figure, int direction) {
  if (ownMouse == false){
    return;
  }
  // If we're not already spinning -
  if (timer == null) {
    spinFigure(figure, direction);

    timer = new Timer.periodic(const Duration(milliseconds: 150),
        (Timer t) => spinFigure(figure, direction));
  }
}

/**
 * Stop any spin that may be in progress.
 */
void stopSpin() {
  if (timer != null) {
    timer.cancel();
    timer = null;
    resultItem=listOfItems[theListNumber];
  }
}

}
