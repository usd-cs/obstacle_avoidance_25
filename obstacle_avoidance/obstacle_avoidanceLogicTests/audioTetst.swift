//
//  obstacle_avoidanceLogicTests.swift
//  obstacle_avoidanceLogicTests
//
//  Created by Jacob Fernandez on 12/12/24.
//

import Foundation
import Testing // Replace with your actual testing framework import
@testable import obstacle_avoidance
//comment so that it will let me push this file
struct AudioQueueTesting {
    var threatLevel: Int
    var objectName: String
    var angle: Int
    var distance: Int

    init() {
        threatLevel = 50
        objectName = "Obstacle"
        angle = 12
        distance = 10
    }

    @Test func testAudioQueueInitializationWithValidData() {
        do {
            let audioQueue = try AudioQueue(threatLevel: threatLevel, objectName: objectName, angle: angle, distance: distance)
            #expect(audioQueue.threatLevel == threatLevel)
            #expect(audioQueue.objectName == objectName)
            #expect(audioQueue.angle == angle)
            #expect(audioQueue.distance == distance)
        } catch {
            //This will always be false, but must catach try
            #expect(Bool(false), "AudioQueue initialization threw an unexpected error")
        }
    }
    @Test func testAudioQueueInitializationThrowsInvalidThreatLevelError() {
        //tests that we get audioqueue of invalid threat level
            let invalidThreatLevel = 150
            do {
                let threatlevel = try AudioQueue(threatLevel: invalidThreatLevel, objectName: objectName, angle: angle, distance: distance)
                #expect(Bool(false), "Expected invalidThreatLevel error but none was thrown")
            } catch AudioQueueError.invalidThreatLevel {
                #expect(true)
            } catch {
                #expect(Bool(false), "Unexpected error type: \(error)")
            }
        }

    @Test func testAudioQueueInitializationThrowsInvalidAngleError() {
            //tets that we get an audioqueue error of invalid angle
            let invalidAngle = 5
            do {
                let angle = try AudioQueue(threatLevel: threatLevel, objectName: objectName, angle: invalidAngle, distance: distance)
                #expect(Bool(false), "Expected invalidAngle error but none was thrown")
            } catch AudioQueueError.invalidAngle {
                #expect(true)
            } catch {
                #expect(Bool(false), "Unexpected error type: \(error)")
            }
        }
    @Test func testAudioQueueInitializationWithBoundaryThreatLevel() {
        //Test verifies that the AudioQueue initializer works correctly for the boundary values of the threat level (0 and 100).

            do {
                let minThreatLevelQueue = try AudioQueue(threatLevel: 0, objectName: objectName, angle: angle, distance: distance)
                #expect(minThreatLevelQueue.threatLevel == 0)

                let maxThreatLevelQueue = try AudioQueue(threatLevel: 100, objectName: objectName, angle: angle, distance: distance)
                #expect(maxThreatLevelQueue.threatLevel == 100)
            } catch {
                #expect(Bool(false), "AudioQueue initialization threw an unexpected error")
            }
        }

    @Test func testAudioQueueInitializationWithBoundaryAngle() {
        //Test: Confirms that the AudioQueue initializer works for all valid angle values (9-12, 1-3).
            for validAngle in [9, 10, 11, 12, 1, 2, 3] {
                do {
                    let audioQueue = try AudioQueue(threatLevel: threatLevel, objectName: objectName, angle: validAngle, distance: distance)
                    #expect(audioQueue.angle == validAngle)
                } catch {
                    #expect(Bool(false), "AudioQueue initialization threw an unexpected error for angle: \(validAngle)")
                }
            }
        }
}
