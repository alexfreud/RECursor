// ----------------------------------------------------------------------------
//
//  RECursor.swift
//
//  @author     Alexander Vasilchenko <avasilchenko@stream.ru>
//  @copyright  Copyright (c) 2020. All rights reserved.
//  @link       https://re-amp.ru/
//  @email      alexfreud@me.com
//
// ----------------------------------------------------------------------------

import Cocoa

public final class RECursor {
    private var cursor: RECursorModel
    private var timer: Timer!
    private var lastSetCursor: NSCursor = NSCursor.current
    private var currentFrame: Int = 0

    convenience init?(cursor fileName: String) {
        guard let fileUrl = Bundle.main.url(forResource: fileName,
                                            withExtension: nil) else {
            return nil
        }
        let cursorData = try? Data(contentsOf: fileUrl)
        self.init(cursor: cursorData)
    }

    init?(cursor data: Data?) {
        guard let data = data else { return nil }
        cursor = data.cursorData
    }

    public func set() {
        if isAnimated {
            createTimer()
        }
        if timer == nil {
            setFrame(0)
        }
    }

    public func unSet() {
        destroyTimer()
    }

    public var isSet: Bool {
        return NSCursor.current == lastSetCursor
    }

    private var isAnimated: Bool {
        return framesCount > 1
    }

    private var framesCount: Int {
        return cursor.frames.count
    }

    @objc private func advanceAnimatedCursor() {
        if timer.isValid {
            setFrame(nextFrame)
        }
    }

    private func createTimer() {
        if timer == nil {
            let interval = TimeInterval(cursor.displayRate)
            timer = Timer.scheduledTimer(timeInterval: interval / 60,
                                         target: self,
                                         selector: #selector(advanceAnimatedCursor),
                                         userInfo: nil,
                                         repeats: true)
        }
    }

    private func destroyTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }

    private func setFrame(_ index: Int) {
        guard cursor.frames.indices.contains(index) else { return }
        let newCursor = cursor.frames[index]
        newCursor.set()
        lastSetCursor = newCursor
    }

    private var nextFrame: Int {
        let newFrame = currentFrame + 1
        currentFrame = newFrame % framesCount
        return currentFrame
    }

}
