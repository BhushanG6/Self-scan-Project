/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The implementation of a single-person pose estimation algorithm, based on the TensorFlow
 project "Pose Detection in the Browser."
*/

import CoreGraphics
import simd
import SwiftUI
import UIKit
import AVFoundation
import VideoToolbox
import CoreVideo
extension PoseBuilder {
    /// Returns a pose constructed using the outputs from the PoseNet model.
    var pose: Pose {
        var pose = Pose()

        // For each joint, find its most likely position and associated confidence
        // by querying the heatmap array for the cell with the greatest
        // confidence and using this to compute its position.
        pose.joints.values.forEach { joint in
            configure(joint: joint)
        }

        // Compute and assign the confidence for the pose.
        pose.confidence = pose.joints.values
            .map { $0.confidence }.reduce(0, +) / Double(Joint.numberOfJoints)

        // Map the pose joints positions back onto the original image.
        pose.joints.values.forEach { joint in
            joint.position = joint.position.applying(modelToInputTransformation)

        }
        print(pose.joints[.leftShoulder]!.position.x)
        leftarm=[Float(pose.joints[.leftShoulder]!.position.x),Float(pose.joints[.leftShoulder]!.position.y)]
        rightarm=[Float(pose.joints[.rightShoulder]!.position.x), Float(pose.joints[.rightShoulder]!.position.y)]
        if eventfront {

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                leftshld1 = [Float(leftarm.x), Float(leftarm.y), 0.0]
                rightshld1 = [Float(rightarm.x), Float(rightarm.y), 0.0]
            mid=(leftshld1+rightshld1)/2
           // print("turn")
//                print("-----------------------------------------------")
//                    print("Left Shoulder 1 is ", leftshld1)
//
//                    print("Right Shoulder 1 is ", rightshld1)

                                   
                eventfront = false

            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
               
                eventleft = true
            }
        }
        if eventleft {

           // DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            leftshld2 = [Float(leftarm.x), Float(leftarm.y), 0.0]
            rightshld2 = [Float(rightarm.x), Float(rightarm.y), 0.0]
        r = Double(self.distance3D(vector1: leftshld1, vector2: rightshld1))/2
        disp = Double(self.distance3D(vector1: leftshld1, vector2: leftshld2))
        var v1=leftshld1-mid
        var v2=leftshld2-mid
        //ang=asin(disp/(2*r))*2
        var m=sqrt(pow(v1.x,2)+pow(v1.y,2)+pow(v1.z,2))*(sqrt(pow(v2.x,2)+pow(v2.y,2)+pow(v2.z,2)))
        var dot1=dot(v1,v2)/m
        ang=acos(Double(dot1))
            var ang1=0.0
            if #available(iOS 15.0, *) {
                var d1=Double(distance3D(vector1:leftshld2 , vector2:rightshld2))
                if d1>2*r
                {
                    d1=2*r-10
                }
                ang1 = acos(d1/(2*r))
                print("angle detected", ang1  * (180/3.14159),(distance(leftshld1 , rightshld1)),(distance(leftshld2 , rightshld2)) )
            } else {
                // Fallback on earlier versions
                print("not detected angle")
            }
           
                //theta = ang! * (180/3.14159)
//                    print("Radius is ", r)
     if abs(2*r-Double(self.distance3D(vector1: leftshld2, vector2: rightshld2)))<1 && !firstb
    {
         firstb=true
    }
    if abs(2*r-Double(self.distance3D(vector1: leftshld2, vector2: rightshld2)))<1 && firstb
    {
        print("Turned 360")
    }

        //theta=ang1
//              print("Displacement is ", disp)
//            var max=max()
        if theta < Double(85)
        {
            theta=ang1
        }
        else if theta > Double(85) && theta < Double(170)
        {
            theta=180-ang1
        }
        else if theta > 170 && theta > 260
        {
            theta=270-ang1
        }
        else
        {
            theta=360-ang1

        }
//            if theta! < 180 && bvalue{
//
//                if theta! > 170{
//                    bvalue=false
//
//                }
//
//
//
//                                }
//            if !bvalue{
//                                    theta = 360 - theta!
//
//                }
//                showAngle.layer.cornerCurve
        
       // showAngle.text=String(theta!)
            
        print("Angle Printed  =======", ang)

                            

                            

                            

//                            switch theta{
//
//
//
//                            case 0..<10:
//
//                                if angArray[0]==true
//
//                                {
//
//                                    angArray[0]=false
//
//                                    return textToSpeech(Number: 0)
//
//                                }
//
//
//
//                            case 28..<35:
//
//
//
//                                if angArray[30]==true
//
//                                {
//
//                                    angArray[30]=false
//
//                                    return textToSpeech(Number: 30)
//
//                                }
//
//                            case 55..<63:
//
//
//
//                                if angArray[60]==true
//
//                                {
//
//                                    angArray[60]=false
//
//                                    return textToSpeech(Number: 60)
//
//                                }
//
//                            case 85..<92:
//
//                                if angArray[90]==true
//
//                                {
//
//                                    angArray[90]=false
//
//                                    return textToSpeech(Number: 90)
//
//                                }
//
//                            case 115..<123:
//
//
//                                if angArray[120]==true
//
//                                {
//
//                                    angArray[120]=false
//
//                                    return textToSpeech(Number: 120)
//
//                                }
//
//                            case 145..<153:
//
//
//                                if angArray[150]==true
//
//                                {
//
//                                    angArray[150]=false
//
//                                    return textToSpeech(Number: 150)
//
//                                }
//
//                            case 170..<185:
//
//                                if angArray[180]==true
//
//                                {
//
//                                    angArray[180]=false
//
//                                    return textToSpeech(Number: 180)
//
//                                }
//
//                            case 205..<213:
//
//
//                                if angArray[210]==true
//
//                                {
//
//                                    angArray[210]=false
//
//                                    return textToSpeech(Number: 210)
//
//                                }
//
//                            case 235..<243:
//
//
//                                if angArray[240]==true
//
//                                {
//
//                                    angArray[240]=false
//
//                                    return textToSpeech(Number: 240)
//
//                                }
//
//                            case 265..<273:
//
//
//                                if angArray[270]==true
//
//                                {
//
//                                    angArray[270]=false
//
//                                    return textToSpeech(Number: 270)
//
//                                }
//
//                            case 295..<303:
//
//
//                                if angArray[300]==true
//
//                                {
//
//                                    angArray[300]=false
//
//                                    return textToSpeech(Number: 300)
//
//                                }
//
//                            case 325..<333:
//
//                                if angArray[330]==true
//
//                                {
//
//                                    angArray[330]=false
//
//                                    return textToSpeech(Number: 330)
//
//                                }
//
//                            case 340..<360:
//
//
//                                if angArray[360]==true
//
//                                {
//
//                                    angArray[360]=false
//
//                                    return textToSpeech(Number: 360)
//
//                                }
//
//                            default:
//
//                                return
//
//                            }
        //}
        }

        return pose
    }
    func textToSpeech(Number: Int){

            let utterance = AVSpeechUtterance(string: "\(Number) Degrees")



            // Configure the utterance.

            utterance.rate = 0.57

            utterance.pitchMultiplier = 0.8

            utterance.postUtteranceDelay = 0.2

            utterance.volume = 0.8



            // Retrieve the British English voice.

    //        let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-GB_compact")



            // Assign the voice to the utterance.

            utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-GB_compact")

            

            let synthesizer = AVSpeechSynthesizer()

            synthesizer.speak(utterance)

        }
    func texttospeech(Number: String){

            let utterance = AVSpeechUtterance(string: Number)



            // Configure the utterance.

            utterance.rate = 0.57

            utterance.pitchMultiplier = 0.8

            utterance.postUtteranceDelay = 0.2

            utterance.volume = 0.8



            // Retrieve the British English voice.

    //        let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-GB_compact")



            // Assign the voice to the utterance.

            utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-GB_compact")

            

            let synthesizer = AVSpeechSynthesizer()

            synthesizer.speak(utterance)

        }
    func distance3D(vector1: simd_float3, vector2: simd_float3) -> Float
        {
            let x: Float = (vector1.x - vector2.x) * (vector1.x - vector2.x)
            let y: Float = (vector1.y - vector2.y) * (vector1.y - vector2.y)
            let z: Float = (vector1.z - vector2.z) * (vector1.z - vector2.z)

            let temp = x + y + z
            return Float(sqrtf(Float(temp)))
        }
    /// Sets the joint's properties using the associated cell with the greatest confidence.
    ///
    /// The confidence is obtained from the `heatmap` array output by the PoseNet model.
    /// - parameters:
    ///     - joint: The joint to update.
    private func configure(joint: Joint) {
        // Iterate over the heatmap's associated joint channel to locate the
        // cell with the greatest confidence.
        var bestCell = PoseNetOutput.Cell(0, 0)
        var bestConfidence = 0.0
        for yIndex in 0..<output.height {
            for xIndex in 0..<output.width {
                let currentCell = PoseNetOutput.Cell(yIndex, xIndex)
                let currentConfidence = output.confidence(for: joint.name, at: currentCell)

                // Keep track of the cell with the greatest confidence.
                if currentConfidence > bestConfidence {
                    bestConfidence = currentConfidence
                    bestCell = currentCell
                }
            }
        }

        // Update joint.
        joint.cell = bestCell
        joint.position = output.position(for: joint.name, at: joint.cell)
        joint.confidence = bestConfidence
        joint.isValid = joint.confidence >= configuration.jointConfidenceThreshold
    }
}
