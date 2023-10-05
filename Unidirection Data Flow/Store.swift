//
//  Store.swift
//  Unidirection Data Flow
//
//  Created by Stephen003 on 2023/10/3.
//

import Foundation

protocol ActionType {}
protocol StateType {}
protocol CommandType {}

/// 儲存狀態、對Action反應
class Store<A: ActionType, S: StateType, C: CommandType> {
    let reducer: (_ state: S, _ action: A) -> (S, C?)
    var subscriber: ((_ state: S, _ previousState: S, _ command: C?) -> Void)?
    var state: S
    
    // 接受 reducer 與 一個初始狀態
    init(reducer: @escaping (S, A) -> (S, C?), initialState: S) {
        self.reducer = reducer
        self.state = initialState
    }
    
    func dispatch(_ action: A) {
        let previousState = state
        let (nextState, command) = reducer(state, action)
        state = nextState
        subscriber?(state, previousState, command)
    }
    
    func subscribe(_ handler: @escaping (S, S, C?) -> Void) {
        self.subscriber = handler
    }
    
    func unsubscribe() {
        self.subscriber = nil
    }
}
