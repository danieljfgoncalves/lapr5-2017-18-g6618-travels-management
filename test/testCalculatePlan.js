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

        describe('calculatePlan', function () {
            it('should have all pharmacies in visited array', function(done) {
                var pharmacies = pharmaciesMock.allVisitedPharmacies;
                this.timeout(0);
                chai.request(server).post('/calculatePlan').send(pharmacies).end(function (err, res) {

                    var realLength = 2 + pharmacies.pharmacies.length;
                    res.body.VisitedPharmacies.should.have.length(realLength);
                    done();
                    });
              });
            
    
        });

        describe('calculatePlan', function () {
            it('should have one pharmacy in nonvisited', function(done) {
                var pharmacies = pharmaciesMock.timeRestrictionB4DeparturePharmacies;
                this.timeout(0);
                chai.request(server).post('/calculatePlan').send(pharmacies).end(function (err, res) {

                    assert.ok(res.body.NonVisitedPharmacies[0].name == pharmacies.pharmacies[0].name);
                    assert.ok(res.body.NonVisitedPharmacies[0].latitude == pharmacies.pharmacies[0].latitude);
                    assert.ok(res.body.NonVisitedPharmacies[0].longitude== pharmacies.pharmacies[0].longitude);
                    done();
                    });
              });
            
    
        });

        describe('calculatePlan', function () {
            it('should have departure as first and last node', function(done) {
                var pharmacies = pharmaciesMock.allVisitedPharmacies;
                this.timeout(0);
                chai.request(server).post('/calculatePlan').send(pharmacies).end(function (err, res) {

                    assert.ok(res.body.VisitedPharmacies[0].name == pharmacies.departure.name.toLowerCase());
                    assert.ok(res.body.VisitedPharmacies[0].latitude == pharmacies.departure.latitude);
                    assert.ok(res.body.VisitedPharmacies[0].longitude== pharmacies.departure.longitude);
                    assert.ok(res.body.VisitedPharmacies[res.body.VisitedPharmacies.length - 1].name == pharmacies.departure.name.toLowerCase());
                    assert.ok(res.body.VisitedPharmacies[res.body.VisitedPharmacies.length - 1].latitude == pharmacies.departure.latitude);
                    assert.ok(res.body.VisitedPharmacies[res.body.VisitedPharmacies.length - 1].longitude== pharmacies.departure.longitude);
                    done();
                    });
              });
            
    
        });
    });