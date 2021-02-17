import XCTest
@testable import RECursor

final class RECursorTests: XCTestCase {
    var cursor: RECursor!

    override func setUpWithError() throws {
        let testBundle = Bundle(for: type(of: self))
        
        let fileURL = testBundle.url(forResource: "stopwtch.ani", withExtension: nil)
        XCTAssertNotNil(fileURL)
        let data = try Data(contentsOf: fileURL!)
        XCTAssertNotNil(data)
        cursor = RECursor()
        cursor.cursorData = data
    }

    override func tearDownWithError() throws {
        cursor = nil
    }

    func testRiffMetadataRead() {
        let riffData = cursor.riffInfoChunk
        let fileFormat = riffData.chunkId.stringValue
        let riffFormat = riffData.format.stringValue
        let riffSize = riffData.size
        XCTAssertEqual(fileFormat, Inner.riff)
        XCTAssertEqual(riffFormat, Inner.acon)
        XCTAssertEqual(riffSize, 6712)
    }

    func testReadFrames() throws {
        let chunks = chunk()
        let frames = try cursor.readImages(chunks: chunks)
        XCTAssertFalse(frames.isEmpty)
        XCTAssertEqual(frames.count, 8)
    }

    func testTitle() {
        let chunks = chunk()
        let title = cursor.titleInfo(chunks)
        XCTAssertEqual(title, "Stopwatch")
    }

    func testArtist() {
        let chunks = chunk()
        let artist = cursor.artistInfo(chunks)
        XCTAssertEqual(artist, "Microsoft Corporation, Copyright 1993")
    }

    func chunk() -> [Chunk] {
        return cursor.parseChunks(with: DWORD(cursor.cursorData.count))
    }

    static var allTests = [
        ("testRiffMetadataRead", testRiffMetadataRead),
        ("testTitle", testTitle),
        ("testReadFrames", testReadFrames),
        ("testArtist", testArtist),
        ("chunk", chunk),
    ] as [Any]
}
