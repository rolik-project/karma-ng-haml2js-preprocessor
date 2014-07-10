describe 'preprocessors haml2js', ->
  chai = require('chai')

  templateHelpers = require('./helpers/template_cache')
  chai.use(templateHelpers)

  expect = chai.expect

  haml2js = require '../lib/haml2js'
  logger = create: -> {debug: ->}
  process = null

  # TODO(vojta): refactor this somehow ;-) it's copy pasted from lib/file-list.js
  File = (path, mtime) ->
    @path = path
    @originalPath = path
    @contentPath = path
    @mtime = mtime
    @isUrl = false

  createPreprocessor = (config = {}) ->
    haml2js logger, 'test', config

  beforeEach ->
    process = createPreprocessor()

  it 'should convert haml to js code', (done) ->
    file = new File 'test/support/file1.haml'

    process file, (processedContent) ->
      expect(processedContent)
        .to.defineModule('support/file1.html').and
        .to.defineTemplateId('support/file1.html').and
        .to.haveContent '<html>\n  <body>\n    <h1>\n      foo\n      bar\\\n    </h1>\n  </body>\n</html>\n'
      done()


  it 'should change path to *.js', (done) ->
    file = new File 'test/support/file1.haml'

    process file, (processedContent) ->
      expect(file.path).to.equal 'test/support/file1.haml.js'
      done()


  it 'should preserve Windows new lines', (done) ->
    file = new File 'test/support/file2.haml'

    process file, (processedContent) ->
      expect(processedContent).to.not.contain '\r'
      done()

  describe 'options', ->
    describe 'stripPrefix', ->
      beforeEach ->
        process = createPreprocessor stripPrefix: 'test/'


      it 'strips the given prefix from the file path', (done) ->
        file = new File 'test/support/file1.haml'

        process file, (processedContent) ->
          expect(processedContent)
            .to.defineModule('support/file1.html').and
            .to.defineTemplateId('support/file1.html').and
            .to.haveContent '<html>\n  <body>\n    <h1>\n      foo\n      bar\\\n    </h1>\n  </body>\n</html>\n'
          done()


    describe 'prependPrefix', ->
      beforeEach ->
        process = createPreprocessor prependPrefix: 'served/'


      it 'prepends the given prefix from the file path', (done) ->
        file = new File 'test/support/file1.haml'

        process file, (processedContent) ->
          expect(processedContent)
            .to.defineModule('served/support/file1.html').and
            .to.defineTemplateId('served/support/file1.html').and
            .to.haveContent '<html>\n  <body>\n    <h1>\n      foo\n      bar\\\n    </h1>\n  </body>\n</html>\n'
          done()


    describe 'cacheIdFromPath', ->
      beforeEach ->
        process = createPreprocessor
          cacheIdFromPath: (filePath) -> "generated_id_for/#{filePath}"


      it 'invokes custom transform function', (done) ->
        file = new File 'test/support/file1.haml'

        process file, (processedContent) ->
          expect(processedContent)
            .to.defineModule('generated_id_for/support/file1.html').and
            .to.defineTemplateId('generated_id_for/support/file1.html').and
            .to.haveContent '<html>\n  <body>\n    <h1>\n      foo\n      bar\\\n    </h1>\n  </body>\n</html>\n'
          done()

    describe 'moduleName', ->
      beforeEach ->
        process = createPreprocessor
          moduleName: 'foo'

      it 'should generate code with a given module name', ->
        file1 = new File 'test/support/file1.haml'
        file2 = new File 'test/support/file2.haml'

        process file1, (processedContent) ->
          expect(processedContent)
            .to.defineModule('foo').and
            .to.defineTemplateId('support/file1.html').and
            .to.haveContent '<html>\n  <body>\n    <h1>\n      foo\n      bar\\\n    </h1>\n  </body>\n</html>\n'

        process file2, (processedContent) ->
          expect(processedContent)
            .to.defineModule('foo').and
            .to.defineTemplateId('support/file2.html').and
            .to.haveContent '<html>\n  <body>\n    <h1>\n      oof\n      rab\\\n    </h1>\n  </body>\n</html>\n'