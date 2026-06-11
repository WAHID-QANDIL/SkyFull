import Swinject

final class AppAssembly: Assembly {

    func assemble(container: Container) {

        container.register(WeatherServiceProtocol.self) { _ in
            WeatherService()
        }.inObjectScope(.container)

        container.register(WeatherRepositoryProtocol.self) { resolver in
            WeatherRepository(
                service: resolver.resolve(WeatherServiceProtocol.self)!
            )
        }.inObjectScope(.container)

        container.register(WeatherViewModel.self) { resolver in
            WeatherViewModel(
                repository: resolver.resolve(WeatherRepositoryProtocol.self)!
            )
        }
    }
}
