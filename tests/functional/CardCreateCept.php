<?php

// @group cards create

/* @var \Codeception\Scenario $scenario */
$guy = new TestGuy($scenario);
$guy->wantTo('create a card');

// create valid card
$guy->sendPOST('/cards', [
    'name' => 'project a',
]);
$guy->seeResponseCodeIs(201);
$guy->seeResponseIsJson();
$guy->seeHttpHeader('Location', '/cards/3');
$guy->seeResponseContainsJson(['id' => 3]);

// no name
$guy->sendPOST('/cards', []);
$guy->seeResponseCodeIs(400);
$guy->seeResponseIsJson();
$guy->seeResponseJsonMatchesJsonPath('$.message');