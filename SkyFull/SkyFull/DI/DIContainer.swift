import Swinject
final class DIContainer {

    static let shared = DIContainer()

    private let assembler: Assembler
    var resolver: Resolver { assembler.resolver }

    private init() {
        assembler = Assembler([AppAssembly()])
    }
    
    func resolve<T>(_ serviceType: T.Type) -> T {
        guard let value = resolver.resolve(serviceType) else {
            fatalError("DIContainer: no registration found for \(serviceType).")
        }
        return value
    }
}
