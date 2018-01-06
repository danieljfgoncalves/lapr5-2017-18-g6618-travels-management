process.env.NODE_ENV = 'test';
var chai = require('chai');
var chaiHttp = require('chai-http');
var Promise = require('bluebird');
var server = require('../app');
var should = chai.should();
var assert = chai.assert;
var planRoute = require('../routes/calculatePlan');
var pharmaciesMock = require('./pharmaciesObj');
chai.use(chaiHttp);


describe('  ***  TRAVELS MANAGEMENT TESTS  ***  ', function () {
    
        describe('calculatePlan', function () {
            it('should respond with message if found url', function(done) {
                var pharmacies = pharmaciesMock.pharmaciesWithURL;
                
                this.timeout(0);
                chai.request(server).post('/calculatePlan').send(pharmacies).end(function (err, res) {
                 
                    res.body.should.contain({
                        "Message": "Plan calculation requested with success. Should respond within moments."
                    });
                    done();
                });
              });
            
    
        });

        describe('calculatePlan', function () {
            it('should respond with plan if not found url', function(done) {
                var pharmacies = pharmaciesMock.pharmaciesWithoutURL;
                
                this.timeout(0);
                chai.request(server).post('/calculatePlan').send(pharmacies).end(function (err, res) {
                 
                    !res.body.should.contain({
                        "Message": "Plan calculation requested with success. Should respond within moments."
                    });
                    done();
                });
              });
            
    
        });


        describe('calculatePlan', function () {
            it('should respond with 401 if no departure', function(done) {
                var pharmacies = pharmaciesMock.pharmaciesWithoutDeparture;
                this.timeout(0);
                chai.request(server).post('/calculatePlan').send(pharmacies).end(function (err, res) {
               
                    res.should.have.status(400);
                    done();
                });
              });
            
    
        });

        describe('calculatePlan', function () {
            it('should respond with 401 if not enough pharmacies', function(done) {
                var pharmacies = pharmaciesMock.notEnoughPharmacies;
                this.timeout(0);
                chai.request(server).post('/calculatePlan').send(pharmacies).end(function (err, res) {
                    
                    res.should.have.status(400);
                    done();
                });
              });
            
    
        });
    });