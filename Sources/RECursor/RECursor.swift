//
//  Cursor.swift
//  TableView
//
//  Created by Александр Васильченко on 16.02.2021.
//

import Cocoa

public final class RECursor {

    private(set) var title: String?
    private(set) var artist: String?
    private var metadata: AniHeader!
    private var frames: [NSCursor] = []
    private var rate: [Int]?
    private var seq: [Int]?

    private static var timer: Timer!
    private var currentFrame: Int = 0
    private var currentSeqIndex: Int = 0

    internal var cursorData: Data!
    internal init() { }

    public convenience init(cursor fileName: String) throws {
        guard let fileUrl = Bundle.main.url(forResource: fileName,
                                            withExtension: nil) else {
            throw CursorError.noCursorFile(fileName: fileName)
        }
        let cursorData = try Data(contentsOf: fileUrl)
        try self.init(cursor: cursorData)
    }

    public init(cursor data: Data?) throws {
        guard let data = data else { throw CursorError.noCursorData }
        cursorData = data
        if let cursorImage = NSImage(data: cursorData) {
            let cursor = NSCursor(image: cursorImage, hotSpot: .zero)
            frames.append(cursor)
            return
        }
        try process()
    }

    deinit {
        RECursor.destroyTimer()
    }

    // MARK: - Public functions

    public func set() {
        RECursor.destroyTimer()
        if isAnimated {
            createTimer()
        }
        if RECursor.timer == nil {
            setFrame(0)
        }
    }

    public static func unSet() {
        destroyTimer()
    }

    // MARK: - Private

    private var isAnimated: Bool {
        return framesCount > 1
    }

    private var framesCount: Int {
        return frames.count
    }

    @objc private func advanceAnimatedCursor() {
        if RECursor.timer.isValid {
            setFrame(nextFrame)
        }
        if let rate = rate, !rate.isEmpty {
            RECursor.destroyTimer()
            createTimer()
        }
    }

    private func createTimer() {
        if RECursor.timer == nil {
            RECursor.timer = Timer.scheduledTimer(timeInterval: nextRate / 60,
                                         target: self,
                                         selector: #selector(advanceAnimatedCursor),
                                         userInfo: nil,
                                         repeats: true)
        }
    }

    private static func destroyTimer() {
        if RECursor.timer != nil {
            RECursor.timer.invalidate()
            RECursor.timer = nil
        }
    }

    private func setFrame(_ index: Int) {
        guard frames.indices.contains(index) else { return }
        let newCursor = frames[index]
        newCursor.set()
    }

    private var nextFrame: Int {
        if let sequence = seq, !sequence.isEmpty {
            if sequence.indices.contains(currentSeqIndex) {
                currentFrame = sequence[currentSeqIndex]
            }
        } else {
            let newFrame = currentFrame + 1
            currentFrame = newFrame % framesCount
        }
        return currentFrame
    }

    private var nextRate: TimeInterval {
        var currentRate: TimeInterval = 0
        if let rate = rate, !rate.isEmpty {
            let newSeqIndex = currentSeqIndex + 1
            let newRateIndex = newSeqIndex % rate.count
            if rate.indices.contains(newRateIndex) {
                currentRate = TimeInterval(rate[newRateIndex])
            }
            currentSeqIndex = newRateIndex
        } else {
            currentRate = TimeInterval(metadata.iDispRate)
        }
        return currentRate
    }

    private func process() throws {
        try checkRiffValid()
        let chunks = parseChunks(with: DWORD(cursorData.count))
        guard !chunks.isEmpty else {
            throw CursorError.noChunksData
        }
        metadata = try parseAniMetadata(chunks)
        frames = try readImages(chunks: chunks)
        title = titleInfo(chunks)
        artist = artistInfo(chunks)
        rate = readArray(chunks: chunks, name: Inner.rate)
        seq = readArray(chunks: chunks, name: Inner.seq)
        // clean up
        cursorData = nil
    }

    private func checkRiffValid() throws {
        guard !cursorData.isEmpty && cursorData.count > 11 else {
            throw CursorError.emptyData
        }
        let riffChunk = riffInfoChunk
        let fileFormat = riffChunk.chunkId.stringValue
        guard fileFormat == Inner.riff else {
            throw CursorError.noRIFFFormat(format: fileFormat)
        }
        let riffFormat = riffChunk.format.stringValue
        guard riffFormat == Inner.acon else {
            throw CursorError.noAconFormat(format: riffFormat)
        }
    }

    // MARK: - Internal

    internal var riffInfoChunk: RiffInfo {
        return cursorData[0..<12].object(at: 0)
    }

    internal func titleInfo(_ chunks: [Chunk]) -> String? {
        guard let titleChunk = chunks.first(where: { $0.chunkId == Inner.info })?.subChunks?
            .first(where: { $0.chunkId == Inner.inam }) else { return nil }
        return cursorData[titleChunk.range].stringValue
    }

    internal func artistInfo(_ chunks: [Chunk]) -> String? {
        guard let artistChunk = chunks.first(where: { $0.chunkId == Inner.info })?.subChunks?
            .first(where: { $0.chunkId == Inner.iart }) else { return nil }
        return cursorData[artistChunk.range].stringValue
    }

    internal func parseAniMetadata(_ chunks: [Chunk]) throws -> AniHeader {
        guard let metadataChunk = chunks.first(where: { $0.chunkId == Inner.anih }) else {
            throw CursorError.noAnihChunk
        }
        return cursorData.object(at: metadataChunk.range.lowerBound)
    }

    internal func parseChunks(with size: DWORD, baseOffset: Int = 12) -> [Chunk] {
        var offset = baseOffset
        var chunks: [Chunk] = []

        while true {
            let chunkInfo: ChunkInfo = cursorData.object(at: offset)

            switch chunkInfo.chunkId.stringValue {
            case Inner.list:
                let listChunk: RiffInfo = cursorData.object(at: offset)
                let subChunks = parseChunks(with: listChunk.size, baseOffset: offset + 12)
                let beginOfChunk = offset + 12
                let chunk = Chunk(chunkId: listChunk.format.stringValue,
                                  size: Int(chunkInfo.size),
                                  range: beginOfChunk..<beginOfChunk + Int(chunkInfo.size), subChunks: subChunks)
                chunks.append(chunk)
                print("Chunk ID: \(listChunk.format.stringValue)")
            default:
                let beginOfChunk = offset + 8
                let chunk = Chunk(chunkId: chunkInfo.chunkId.stringValue,
                                  size: Int(chunkInfo.size),
                                  range: beginOfChunk..<beginOfChunk + Int(chunkInfo.size), subChunks: nil)
                chunks.append(chunk)
                print("Chunk ID: \(chunkInfo.chunkId.stringValue)")
            }
            offset += Int(chunkInfo.size) + 8
            if offset >= size { break }
        }
        return chunks
    }

    internal func readImages(chunks: [Chunk]) throws -> [NSCursor] {
        guard let imagesChunk = chunks.first(where: { $0.chunkId == Inner.fram })?.subChunks else {
            throw CursorError.noFramChunk
        }
        return try imagesChunk.compactMap { chunk in
            guard chunk.chunkId == Inner.icon else {
                throw CursorError.noIconChunk(format: chunk.chunkId)
            }
            let imageData = cursorData[chunk.range]
            guard let image = NSImage(data: imageData) else {
                return nil
            }
            return NSCursor(image: image, hotSpot: imageData.hotSpot)
        }
    }

    internal func readArray(chunks: [Chunk], name: String) -> [Int]? {
        guard let arrayChunk = chunks.first(where: { $0.chunkId == name }) else {
            return nil
        }
        let arrayData = cursorData[arrayChunk.range]
        return arrayData.arrayValue
    }

}

