// PUBLISH DI MODULE
module.exports = {
  'preprocessor:ng-haml2js': ['factory', require('./haml2js')],
  // TODO(vojta): remove this in 0.11
  'preprocessor:haml2js': ['factory', require('./haml2js')]
};
